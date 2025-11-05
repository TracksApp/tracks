package handlers

import (
	"html/template"
	"net/http"
	"time"

	"github.com/TracksApp/tracks/internal/database"
	"github.com/TracksApp/tracks/internal/middleware"
	"github.com/TracksApp/tracks/internal/models"
	"github.com/TracksApp/tracks/internal/services"
	"github.com/gin-gonic/gin"
)

// WebHandler handles web UI routes
type WebHandler struct {
	authService *services.AuthService
	templates   *template.Template
}

// NewWebHandler creates a new WebHandler
func NewWebHandler(authService *services.AuthService, templates *template.Template) *WebHandler {
	return &WebHandler{
		authService: authService,
		templates:   templates,
	}
}

// ShowLogin displays the login page
func (h *WebHandler) ShowLogin(c *gin.Context) {
	// Check if this is first time (no users except admin)
	var count int64
	database.DB.Model(&models.User{}).Count(&count)

	data := gin.H{
		"Title":     "Login",
		"FirstTime": count <= 1,
	}

	c.Header("Content-Type", "text/html; charset=utf-8")
	// Execute base template with content template
	err := h.templates.Lookup("base.html").Execute(c.Writer, data)
	if err != nil {
		c.String(500, "Template error: "+err.Error())
		return
	}
}

// HandleLogin processes login form submission
func (h *WebHandler) HandleLogin(c *gin.Context) {
	login := c.PostForm("login")
	password := c.PostForm("password")

	// Authenticate user
	resp, err := h.authService.Login(services.LoginRequest{
		Login:    login,
		Password: password,
	})

	if err != nil {
		var count int64
		database.DB.Model(&models.User{}).Count(&count)

		data := gin.H{
			"Title":     "Login",
			"Error":     "Invalid username or password",
			"FirstTime": count <= 1,
		}
		c.Header("Content-Type", "text/html; charset=utf-8")
		h.templates.ExecuteTemplate(c.Writer, "base.html", data)
		return
	}

	// Set session cookie
	c.SetCookie("tracks_token", resp.Token, 60*60*24*7, "/", "", false, true)

	// Redirect to dashboard
	c.Redirect(http.StatusFound, "/")
}

// HandleLogout logs out the user
func (h *WebHandler) HandleLogout(c *gin.Context) {
	// Clear session cookie
	c.SetCookie("tracks_token", "", -1, "/", "", false, true)
	c.Redirect(http.StatusFound, "/login")
}

// ShowDashboard displays the dashboard
func (h *WebHandler) ShowDashboard(c *gin.Context) {
	user, _ := middleware.GetCurrentUser(c)

	// Get statistics
	var stats struct {
		ActiveTodos     int64
		ActiveProjects  int64
		ActiveContexts  int64
		CompletedToday  int64
	}

	database.DB.Model(&models.Todo{}).Where("user_id = ? AND state = ?", user.ID, "active").Count(&stats.ActiveTodos)
	database.DB.Model(&models.Project{}).Where("user_id = ? AND state = ?", user.ID, "active").Count(&stats.ActiveProjects)
	database.DB.Model(&models.Context{}).Where("user_id = ? AND state = ?", user.ID, "active").Count(&stats.ActiveContexts)

	today := time.Now().Truncate(24 * time.Hour)
	database.DB.Model(&models.Todo{}).
		Where("user_id = ? AND state = ? AND completed_at >= ?", user.ID, "completed", today).
		Count(&stats.CompletedToday)

	// Get recent todos
	var recentTodos []models.Todo
	database.DB.
		Preload("Context").
		Preload("Project").
		Where("user_id = ?", user.ID).
		Order("created_at DESC").
		Limit(10).
		Find(&recentTodos)

	data := gin.H{
		"Title":       "Dashboard",
		"User":        user,
		"Stats":       stats,
		"RecentTodos": recentTodos,
	}

	c.Header("Content-Type", "text/html; charset=utf-8")
	h.templates.ExecuteTemplate(c.Writer, "base.html", data)
}

// ShowAdminUsers displays the user management page
func (h *WebHandler) ShowAdminUsers(c *gin.Context) {
	user, _ := middleware.GetCurrentUser(c)

	// Get all users
	var users []models.User
	database.DB.Order("id ASC").Find(&users)

	data := gin.H{
		"Title": "User Management",
		"User":  user,
		"Users": users,
	}

	c.Header("Content-Type", "text/html; charset=utf-8")
	h.templates.ExecuteTemplate(c.Writer, "base.html", data)
}

// HandleCreateUser processes user creation form
func (h *WebHandler) HandleCreateUser(c *gin.Context) {
	user, _ := middleware.GetCurrentUser(c)

	login := c.PostForm("login")
	password := c.PostForm("password")
	firstName := c.PostForm("first_name")
	lastName := c.PostForm("last_name")
	isAdmin := c.PostForm("is_admin") == "true"

	// Create user
	_, err := h.authService.CreateUser(services.CreateUserRequest{
		Login:     login,
		Password:  password,
		FirstName: firstName,
		LastName:  lastName,
		IsAdmin:   isAdmin,
	})

	if err != nil {
		// Get all users for re-rendering
		var users []models.User
		database.DB.Order("id ASC").Find(&users)

		data := gin.H{
			"Title": "User Management",
			"User":  user,
			"Users": users,
			"Error": err.Error(),
		}
		c.Header("Content-Type", "text/html; charset=utf-8")
		h.templates.ExecuteTemplate(c.Writer, "base.html", data)
		return
	}

	// Redirect back to users page with success message
	c.Redirect(http.StatusFound, "/admin/users?success=User created successfully")
}
