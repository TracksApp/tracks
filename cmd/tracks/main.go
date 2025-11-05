package main

import (
	"embed"
	"flag"
	"fmt"
	"html/template"
	"log"

	"github.com/TracksApp/tracks/internal/config"
	"github.com/TracksApp/tracks/internal/database"
	"github.com/TracksApp/tracks/internal/handlers"
	"github.com/TracksApp/tracks/internal/middleware"
	"github.com/TracksApp/tracks/internal/services"
	"github.com/gin-gonic/gin"
)

//go:embed web/templates/*.html
var templateFS embed.FS

func main() {
	// Parse command line flags
	port := flag.Int("port", 0, "Port to run the server on (overrides SERVER_PORT env var)")
	host := flag.String("host", "", "Host to bind to (overrides SERVER_HOST env var)")
	dbName := flag.String("db-name", "", "SQLite database file path (overrides DB_NAME)")
	flag.Parse()

	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatal("Failed to load configuration:", err)
	}

	// Override config with CLI flags if provided
	if *port != 0 {
		cfg.Server.Port = *port
	}
	if *host != "" {
		cfg.Server.Host = *host
	}
	if *dbName != "" {
		cfg.Database.Name = *dbName
	}

	// Initialize database
	if err := database.Initialize(&cfg.Database); err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer database.Close()

	// Run migrations
	if err := database.AutoMigrate(); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Create default admin user if no users exist
	if err := database.CreateDefaultAdmin(); err != nil {
		log.Fatal("Failed to create default admin:", err)
	}

	// Set Gin mode
	gin.SetMode(cfg.Server.Mode)

	// Create router
	router := gin.Default()

	// Setup routes
	setupRoutes(router, cfg)

	// Start server
	addr := fmt.Sprintf("%s:%d", cfg.Server.Host, cfg.Server.Port)
	log.Printf("Starting Tracks server on %s", addr)
	if err := router.Run(addr); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func setupRoutes(router *gin.Engine, cfg *config.Config) {
	// Parse embedded templates
	tmpl := template.Must(template.ParseFS(templateFS, "web/templates/*.html"))

	// Initialize services
	authService := services.NewAuthService(cfg.Auth.JWTSecret)
	todoService := services.NewTodoService()
	projectService := services.NewProjectService()
	contextService := services.NewContextService()

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(authService)
	todoHandler := handlers.NewTodoHandler(todoService)
	projectHandler := handlers.NewProjectHandler(projectService)
	contextHandler := handlers.NewContextHandler(contextService)
	webHandler := handlers.NewWebHandler(authService, tmpl)

	// Web UI routes (public)
	router.GET("/login", webHandler.ShowLogin)
	router.POST("/login", webHandler.HandleLogin)
	router.GET("/logout", webHandler.HandleLogout)

	// Web UI routes (protected)
	webProtected := router.Group("")
	webProtected.Use(middleware.AuthMiddleware(cfg.Auth.JWTSecret))
	{
		webProtected.GET("/", webHandler.ShowDashboard)
		webProtected.GET("/dashboard", webHandler.ShowDashboard)
		webProtected.GET("/todos", webHandler.ShowTodos)
		webProtected.GET("/projects", webHandler.ShowProjects)
		webProtected.GET("/contexts", webHandler.ShowContexts)

		// Admin web routes
		webAdmin := webProtected.Group("/admin")
		webAdmin.Use(middleware.AdminMiddleware())
		{
			webAdmin.GET("/users", webHandler.ShowAdminUsers)
			webAdmin.POST("/users", webHandler.HandleCreateUser)
		}
	}

	// Public routes
	api := router.Group("/api")
	{
		// Health check
		api.GET("/health", func(c *gin.Context) {
			c.JSON(200, gin.H{"status": "ok"})
		})

		// Auth routes
		auth := api.Group("/auth")
		{
			auth.POST("/login", authHandler.Login)
			auth.POST("/register", authHandler.Register)
			auth.POST("/logout", authHandler.Logout)
		}
	}

	// Protected routes
	protected := api.Group("")
	protected.Use(middleware.AuthMiddleware(cfg.Auth.JWTSecret))
	{
		// User routes
		protected.GET("/me", authHandler.Me)
		protected.POST("/refresh-token", authHandler.RefreshToken)

		// Todo routes
		todos := protected.Group("/todos")
		{
			todos.GET("", todoHandler.ListTodos)
			todos.POST("", todoHandler.CreateTodo)
			todos.GET("/:id", todoHandler.GetTodo)
			todos.PUT("/:id", todoHandler.UpdateTodo)
			todos.DELETE("/:id", todoHandler.DeleteTodo)
			todos.POST("/:id/complete", todoHandler.CompleteTodo)
			todos.POST("/:id/activate", todoHandler.ActivateTodo)
			todos.POST("/:id/defer", todoHandler.DeferTodo)
			todos.POST("/:id/dependencies", todoHandler.AddDependency)
			todos.DELETE("/:id/dependencies/:successor_id", todoHandler.RemoveDependency)
		}

		// Project routes
		projects := protected.Group("/projects")
		{
			projects.GET("", projectHandler.ListProjects)
			projects.POST("", projectHandler.CreateProject)
			projects.GET("/:id", projectHandler.GetProject)
			projects.PUT("/:id", projectHandler.UpdateProject)
			projects.DELETE("/:id", projectHandler.DeleteProject)
			projects.POST("/:id/complete", projectHandler.CompleteProject)
			projects.POST("/:id/activate", projectHandler.ActivateProject)
			projects.POST("/:id/hide", projectHandler.HideProject)
			projects.POST("/:id/review", projectHandler.MarkReviewed)
			projects.GET("/:id/stats", projectHandler.GetProjectStats)
		}

		// Context routes
		contexts := protected.Group("/contexts")
		{
			contexts.GET("", contextHandler.ListContexts)
			contexts.POST("", contextHandler.CreateContext)
			contexts.GET("/:id", contextHandler.GetContext)
			contexts.PUT("/:id", contextHandler.UpdateContext)
			contexts.DELETE("/:id", contextHandler.DeleteContext)
			contexts.POST("/:id/hide", contextHandler.HideContext)
			contexts.POST("/:id/activate", contextHandler.ActivateContext)
			contexts.POST("/:id/close", contextHandler.CloseContext)
			contexts.GET("/:id/stats", contextHandler.GetContextStats)
		}
	}

	// Admin routes (requires authentication + admin role)
	admin := api.Group("/admin")
	admin.Use(middleware.AuthMiddleware(cfg.Auth.JWTSecret))
	admin.Use(middleware.AdminMiddleware())
	{
		admin.POST("/users", authHandler.CreateUser)
	}

	// CORS middleware for development
	router.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE, PATCH")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})
}
