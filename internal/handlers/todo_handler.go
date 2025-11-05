package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/TracksApp/tracks/internal/middleware"
	"github.com/TracksApp/tracks/internal/models"
	"github.com/TracksApp/tracks/internal/services"
	"github.com/gin-gonic/gin"
)

// TodoHandler handles todo endpoints
type TodoHandler struct {
	todoService *services.TodoService
}

// NewTodoHandler creates a new TodoHandler
func NewTodoHandler(todoService *services.TodoService) *TodoHandler {
	return &TodoHandler{
		todoService: todoService,
	}
}

// ListTodos handles GET /api/todos
func (h *TodoHandler) ListTodos(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	// Parse filters from query parameters
	filter := services.ListTodosFilter{
		IncludeTags: c.Query("include_tags") == "true",
	}

	if state := c.Query("state"); state != "" {
		filter.State = models.TodoState(state)
	}

	if contextIDStr := c.Query("context_id"); contextIDStr != "" {
		if contextID, err := strconv.ParseUint(contextIDStr, 10, 32); err == nil {
			id := uint(contextID)
			filter.ContextID = &id
		}
	}

	if projectIDStr := c.Query("project_id"); projectIDStr != "" {
		if projectID, err := strconv.ParseUint(projectIDStr, 10, 32); err == nil {
			id := uint(projectID)
			filter.ProjectID = &id
		}
	}

	if tagName := c.Query("tag"); tagName != "" {
		filter.TagName = &tagName
	}

	if c.Query("starred") == "true" {
		starred := true
		filter.Starred = &starred
	}

	if c.Query("overdue") == "true" {
		overdue := true
		filter.Overdue = &overdue
	}

	if c.Query("due_today") == "true" {
		dueToday := true
		filter.DueToday = &dueToday
	}

	if c.Query("show_from") == "true" {
		showFrom := true
		filter.ShowFrom = &showFrom
	}

	todos, err := h.todoService.GetTodos(userID, filter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, todos)
}

// GetTodo handles GET /api/todos/:id
func (h *TodoHandler) GetTodo(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	todoID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid todo ID"})
		return
	}

	todo, err := h.todoService.GetTodo(userID, uint(todoID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, todo)
}

// CreateTodo handles POST /api/todos
func (h *TodoHandler) CreateTodo(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	var req services.CreateTodoRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	todo, err := h.todoService.CreateTodo(userID, req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, todo)
}

// UpdateTodo handles PUT /api/todos/:id
func (h *TodoHandler) UpdateTodo(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	todoID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid todo ID"})
		return
	}

	var req services.UpdateTodoRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	todo, err := h.todoService.UpdateTodo(userID, uint(todoID), req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, todo)
}

// DeleteTodo handles DELETE /api/todos/:id
func (h *TodoHandler) DeleteTodo(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	todoID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid todo ID"})
		return
	}

	if err := h.todoService.DeleteTodo(userID, uint(todoID)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Todo deleted"})
}

// CompleteTodo handles POST /api/todos/:id/complete
func (h *TodoHandler) CompleteTodo(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	todoID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid todo ID"})
		return
	}

	todo, err := h.todoService.CompleteTodo(userID, uint(todoID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, todo)
}

// ActivateTodo handles POST /api/todos/:id/activate
func (h *TodoHandler) ActivateTodo(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	todoID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid todo ID"})
		return
	}

	todo, err := h.todoService.ActivateTodo(userID, uint(todoID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, todo)
}

// DeferTodo handles POST /api/todos/:id/defer
func (h *TodoHandler) DeferTodo(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	todoID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid todo ID"})
		return
	}

	var req struct {
		ShowFrom time.Time `json:"show_from" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	todo, err := h.todoService.DeferTodo(userID, uint(todoID), req.ShowFrom)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, todo)
}

// AddDependency handles POST /api/todos/:id/dependencies
func (h *TodoHandler) AddDependency(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	predecessorID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid todo ID"})
		return
	}

	var req struct {
		SuccessorID uint `json:"successor_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.todoService.AddDependency(userID, uint(predecessorID), req.SuccessorID); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Dependency added"})
}

// RemoveDependency handles DELETE /api/todos/:id/dependencies/:successor_id
func (h *TodoHandler) RemoveDependency(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	predecessorID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid todo ID"})
		return
	}

	successorID, err := strconv.ParseUint(c.Param("successor_id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid successor ID"})
		return
	}

	if err := h.todoService.RemoveDependency(userID, uint(predecessorID), uint(successorID)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Dependency removed"})
}
