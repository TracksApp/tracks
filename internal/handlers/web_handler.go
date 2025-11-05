package handlers

import (
	"encoding/xml"
	"fmt"
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

// ShowTodos displays the todos page
func (h *WebHandler) ShowTodos(c *gin.Context) {
	user, _ := middleware.GetCurrentUser(c)

	// Get user's todos
	var todos []models.Todo
	database.DB.
		Preload("Context").
		Preload("Project").
		Where("user_id = ?", user.ID).
		Order("created_at DESC").
		Find(&todos)

	// Get user's contexts for the dropdown
	var contexts []models.Context
	database.DB.
		Where("user_id = ? AND state = ?", user.ID, "active").
		Order("position ASC").
		Find(&contexts)

	data := gin.H{
		"Title":    "Todos",
		"User":     user,
		"Todos":    todos,
		"Contexts": contexts,
	}

	c.Header("Content-Type", "text/html; charset=utf-8")
	h.templates.ExecuteTemplate(c.Writer, "base.html", data)
}

// ShowProjects displays the projects page
func (h *WebHandler) ShowProjects(c *gin.Context) {
	user, _ := middleware.GetCurrentUser(c)

	// Get user's projects
	var projects []models.Project
	database.DB.
		Where("user_id = ?", user.ID).
		Order("created_at DESC").
		Find(&projects)

	data := gin.H{
		"Title":    "Projects",
		"User":     user,
		"Projects": projects,
	}

	c.Header("Content-Type", "text/html; charset=utf-8")
	h.templates.ExecuteTemplate(c.Writer, "base.html", data)
}

// ShowContexts displays the contexts page
func (h *WebHandler) ShowContexts(c *gin.Context) {
	user, _ := middleware.GetCurrentUser(c)

	// Get user's contexts
	var contexts []models.Context
	database.DB.
		Where("user_id = ?", user.ID).
		Order("position ASC").
		Find(&contexts)

	data := gin.H{
		"Title":    "Contexts",
		"User":     user,
		"Contexts": contexts,
	}

	c.Header("Content-Type", "text/html; charset=utf-8")
	h.templates.ExecuteTemplate(c.Writer, "base.html", data)
}

// HandleCreateContext processes context creation form
func (h *WebHandler) HandleCreateContext(c *gin.Context) {
	user, _ := middleware.GetCurrentUser(c)

	name := c.PostForm("name")
	if name == "" {
		c.Redirect(http.StatusFound, "/contexts?error=Context name is required")
		return
	}

	// Get the highest position value for proper ordering
	var maxPosition int
	database.DB.Model(&models.Context{}).
		Where("user_id = ?", user.ID).
		Select("COALESCE(MAX(position), 0)").
		Scan(&maxPosition)

	// Create context
	context := models.Context{
		UserID:   user.ID,
		Name:     name,
		State:    "active",
		Position: maxPosition + 1,
	}

	if err := database.DB.Create(&context).Error; err != nil {
		c.Redirect(http.StatusFound, "/contexts?error="+err.Error())
		return
	}

	// Redirect back to contexts page
	c.Redirect(http.StatusFound, "/contexts")
}

// HandleDeleteContext processes context deletion
func (h *WebHandler) HandleDeleteContext(c *gin.Context) {
	user, _ := middleware.GetCurrentUser(c)
	contextID := c.Param("id")

	// Verify context belongs to user
	var context models.Context
	if err := database.DB.Where("id = ? AND user_id = ?", contextID, user.ID).First(&context).Error; err != nil {
		c.Redirect(http.StatusFound, "/contexts?error=Context not found")
		return
	}

	// Delete context
	if err := database.DB.Delete(&context).Error; err != nil {
		c.Redirect(http.StatusFound, "/contexts?error="+err.Error())
		return
	}

	// Redirect back to contexts page
	c.Redirect(http.StatusFound, "/contexts")
}

// HandleCreateTodo processes todo creation form
func (h *WebHandler) HandleCreateTodo(c *gin.Context) {
	user, _ := middleware.GetCurrentUser(c)

	description := c.PostForm("description")
	if description == "" {
		c.Redirect(http.StatusFound, "/todos?error=Description is required")
		return
	}

	notes := c.PostForm("notes")
	contextIDStr := c.PostForm("context_id")
	dueDateStr := c.PostForm("due_date")

	// Parse context ID (required)
	if contextIDStr == "" {
		c.Redirect(http.StatusFound, "/todos?error=Context is required")
		return
	}

	var contextID uint
	if _, err := fmt.Sscanf(contextIDStr, "%d", &contextID); err != nil {
		c.Redirect(http.StatusFound, "/todos?error=Invalid context")
		return
	}

	// Verify context exists and belongs to user
	var context models.Context
	if err := database.DB.Where("id = ? AND user_id = ?", contextID, user.ID).First(&context).Error; err != nil {
		c.Redirect(http.StatusFound, "/todos?error=Context not found")
		return
	}

	// Create todo
	todo := models.Todo{
		UserID:      user.ID,
		ContextID:   contextID,
		Description: description,
		Notes:       notes,
		State:       "active",
	}

	// Parse and set due date if provided
	if dueDateStr != "" {
		if dueDate, err := time.Parse("2006-01-02", dueDateStr); err == nil {
			todo.DueDate = &dueDate
		}
	}

	if err := database.DB.Create(&todo).Error; err != nil {
		c.Redirect(http.StatusFound, "/todos?error="+err.Error())
		return
	}

	// Redirect back to todos page
	c.Redirect(http.StatusFound, "/todos")
}

// HandleDeleteTodo processes todo deletion
func (h *WebHandler) HandleDeleteTodo(c *gin.Context) {
	user, _ := middleware.GetCurrentUser(c)
	todoID := c.Param("id")

	// Verify todo belongs to user
	var todo models.Todo
	if err := database.DB.Where("id = ? AND user_id = ?", todoID, user.ID).First(&todo).Error; err != nil {
		c.Redirect(http.StatusFound, "/todos?error=Todo not found")
		return
	}

	// Delete todo
	if err := database.DB.Delete(&todo).Error; err != nil {
		c.Redirect(http.StatusFound, "/todos?error="+err.Error())
		return
	}

	// Redirect back to todos page
	c.Redirect(http.StatusFound, "/todos")
}

// RSS feed structures
type RSSFeed struct {
	XMLName xml.Name `xml:"rss"`
	Version string   `xml:"version,attr"`
	Channel RSSChannel
}

type RSSChannel struct {
	XMLName     xml.Name `xml:"channel"`
	Title       string   `xml:"title"`
	Link        string   `xml:"link"`
	Description string   `xml:"description"`
	Language    string   `xml:"language"`
	PubDate     string   `xml:"pubDate"`
	Items       []RSSItem
}

type RSSItem struct {
	XMLName     xml.Name `xml:"item"`
	Title       string   `xml:"title"`
	Link        string   `xml:"link"`
	Description string   `xml:"description"`
	PubDate     string   `xml:"pubDate"`
	GUID        string   `xml:"guid"`
}

// HandleContextFeed generates an RSS feed for todos in a specific context
func (h *WebHandler) HandleContextFeed(c *gin.Context) {
	user, _ := middleware.GetCurrentUser(c)
	contextID := c.Param("id")

	// Verify context belongs to user
	var context models.Context
	if err := database.DB.Where("id = ? AND user_id = ?", contextID, user.ID).First(&context).Error; err != nil {
		c.XML(http.StatusNotFound, gin.H{"error": "Context not found"})
		return
	}

	// Get all todos for this context
	var todos []models.Todo
	database.DB.
		Preload("Project").
		Where("user_id = ? AND context_id = ?", user.ID, contextID).
		Order("created_at DESC").
		Find(&todos)

	// Build RSS feed
	feed := RSSFeed{
		Version: "2.0",
		Channel: RSSChannel{
			Title:       fmt.Sprintf("Tracks - %s Todos", context.Name),
			Link:        fmt.Sprintf("%s/contexts/%s", c.Request.Host, contextID),
			Description: fmt.Sprintf("Todos for context: %s", context.Name),
			Language:    "en-us",
			PubDate:     time.Now().Format(time.RFC1123Z),
			Items:       make([]RSSItem, 0, len(todos)),
		},
	}

	// Add todos as RSS items
	for _, todo := range todos {
		description := todo.Description
		if todo.Notes != "" {
			description += "\n\n" + todo.Notes
		}
		if todo.Project != nil {
			description += fmt.Sprintf("\n\nProject: %s", todo.Project.Name)
		}
		if todo.DueDate != nil {
			description += fmt.Sprintf("\n\nDue: %s", todo.DueDate.Format("2006-01-02"))
		}

		item := RSSItem{
			Title:       todo.Description,
			Link:        fmt.Sprintf("%s/todos/%d", c.Request.Host, todo.ID),
			Description: description,
			PubDate:     todo.CreatedAt.Format(time.RFC1123Z),
			GUID:        fmt.Sprintf("todo-%d", todo.ID),
		}
		feed.Channel.Items = append(feed.Channel.Items, item)
	}

	// Return RSS XML
	c.Header("Content-Type", "application/rss+xml; charset=utf-8")
	xmlData, err := xml.MarshalIndent(feed, "", "  ")
	if err != nil {
		c.XML(http.StatusInternalServerError, gin.H{"error": "Failed to generate RSS feed"})
		return
	}

	c.Data(http.StatusOK, "application/rss+xml; charset=utf-8", append([]byte(xml.Header), xmlData...))
}
