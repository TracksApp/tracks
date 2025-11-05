package services

import (
	"errors"
	"fmt"
	"time"

	"github.com/TracksApp/tracks/internal/database"
	"github.com/TracksApp/tracks/internal/models"
	"gorm.io/gorm"
)

// TodoService handles todo business logic
type TodoService struct{}

// NewTodoService creates a new TodoService
func NewTodoService() *TodoService {
	return &TodoService{}
}

// CreateTodoRequest represents a todo creation request
type CreateTodoRequest struct {
	Description string     `json:"description" binding:"required"`
	Notes       string     `json:"notes"`
	ContextID   uint       `json:"context_id" binding:"required"`
	ProjectID   *uint      `json:"project_id"`
	DueDate     *time.Time `json:"due_date"`
	ShowFrom    *time.Time `json:"show_from"`
	Starred     bool       `json:"starred"`
	TagNames    []string   `json:"tags"`
}

// UpdateTodoRequest represents a todo update request
type UpdateTodoRequest struct {
	Description *string    `json:"description"`
	Notes       *string    `json:"notes"`
	ContextID   *uint      `json:"context_id"`
	ProjectID   *uint      `json:"project_id"`
	DueDate     *time.Time `json:"due_date"`
	ShowFrom    *time.Time `json:"show_from"`
	Starred     *bool      `json:"starred"`
	TagNames    []string   `json:"tags"`
}

// ListTodosFilter represents filters for listing todos
type ListTodosFilter struct {
	State       models.TodoState
	ContextID   *uint
	ProjectID   *uint
	TagName     *string
	Starred     *bool
	Overdue     *bool
	DueToday    *bool
	ShowFrom    *bool // If true, only show todos where show_from has passed
	IncludeTags bool
}

// GetTodos returns todos for a user with optional filters
func (s *TodoService) GetTodos(userID uint, filter ListTodosFilter) ([]models.Todo, error) {
	var todos []models.Todo

	query := database.DB.Where("user_id = ?", userID)

	// Apply filters
	if filter.State != "" {
		query = query.Where("state = ?", filter.State)
	}

	if filter.ContextID != nil {
		query = query.Where("context_id = ?", *filter.ContextID)
	}

	if filter.ProjectID != nil {
		query = query.Where("project_id = ?", *filter.ProjectID)
	}

	if filter.Starred != nil {
		query = query.Where("starred = ?", *filter.Starred)
	}

	if filter.Overdue != nil && *filter.Overdue {
		query = query.Where("due_date < ? AND state = ?", time.Now(), models.TodoStateActive)
	}

	if filter.DueToday != nil && *filter.DueToday {
		today := time.Now().Truncate(24 * time.Hour)
		tomorrow := today.Add(24 * time.Hour)
		query = query.Where("due_date >= ? AND due_date < ?", today, tomorrow)
	}

	if filter.ShowFrom != nil && *filter.ShowFrom {
		now := time.Now()
		query = query.Where("show_from IS NULL OR show_from <= ?", now)
	}

	// Preload associations
	query = query.Preload("Context").Preload("Project")

	// Filter by tag
	if filter.TagName != nil {
		query = query.Joins("JOIN taggings ON taggings.taggable_id = todos.id AND taggings.taggable_type = ?", "Todo").
			Joins("JOIN tags ON tags.id = taggings.tag_id").
			Where("tags.name = ? AND tags.user_id = ?", *filter.TagName, userID)
	}

	// Order by created_at
	query = query.Order("created_at ASC")

	if err := query.Find(&todos).Error; err != nil {
		return nil, err
	}

	// Load tags if requested
	if filter.IncludeTags {
		for i := range todos {
			if err := s.loadTodoTags(&todos[i]); err != nil {
				return nil, err
			}
		}
	}

	return todos, nil
}

// GetTodo returns a single todo by ID
func (s *TodoService) GetTodo(userID, todoID uint) (*models.Todo, error) {
	var todo models.Todo

	if err := database.DB.
		Where("id = ? AND user_id = ?", todoID, userID).
		Preload("Context").
		Preload("Project").
		Preload("Attachments").
		Preload("Predecessors.Predecessor").
		Preload("Successors.Successor").
		First(&todo).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("todo not found")
		}
		return nil, err
	}

	// Load tags manually through taggings
	if err := s.loadTodoTags(&todo); err != nil {
		return nil, err
	}

	return &todo, nil
}

// loadTodoTags loads tags for a todo through the polymorphic taggings
func (s *TodoService) loadTodoTags(todo *models.Todo) error {
	var tags []models.Tag

	err := database.DB.
		Joins("JOIN taggings ON taggings.tag_id = tags.id").
		Where("taggings.taggable_id = ? AND taggings.taggable_type = ?", todo.ID, "Todo").
		Find(&tags).Error

	if err != nil {
		return err
	}

	todo.Tags = tags
	return nil
}

// CreateTodo creates a new todo
func (s *TodoService) CreateTodo(userID uint, req CreateTodoRequest) (*models.Todo, error) {
	// Verify context belongs to user
	var context models.Context
	if err := database.DB.Where("id = ? AND user_id = ?", req.ContextID, userID).First(&context).Error; err != nil {
		return nil, fmt.Errorf("context not found")
	}

	// Verify project belongs to user if provided
	if req.ProjectID != nil {
		var project models.Project
		if err := database.DB.Where("id = ? AND user_id = ?", *req.ProjectID, userID).First(&project).Error; err != nil {
			return nil, fmt.Errorf("project not found")
		}
	}

	// Determine initial state
	state := models.TodoStateActive
	if req.ShowFrom != nil && req.ShowFrom.After(time.Now()) {
		state = models.TodoStateDeferred
	}

	// Create todo
	todo := models.Todo{
		UserID:      userID,
		Description: req.Description,
		Notes:       req.Notes,
		ContextID:   req.ContextID,
		ProjectID:   req.ProjectID,
		DueDate:     req.DueDate,
		ShowFrom:    req.ShowFrom,
		Starred:     req.Starred,
		State:       state,
	}

	// Begin transaction
	tx := database.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	if err := tx.Create(&todo).Error; err != nil {
		tx.Rollback()
		return nil, err
	}

	// Handle tags
	if len(req.TagNames) > 0 {
		tagService := NewTagService()
		if err := tagService.SetTodoTags(tx, userID, todo.ID, req.TagNames); err != nil {
			tx.Rollback()
			return nil, err
		}
	}

	if err := tx.Commit().Error; err != nil {
		return nil, err
	}

	// Reload with associations
	return s.GetTodo(userID, todo.ID)
}

// UpdateTodo updates a todo
func (s *TodoService) UpdateTodo(userID, todoID uint, req UpdateTodoRequest) (*models.Todo, error) {
	todo, err := s.GetTodo(userID, todoID)
	if err != nil {
		return nil, err
	}

	// Begin transaction
	tx := database.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Update fields
	if req.Description != nil {
		todo.Description = *req.Description
	}
	if req.Notes != nil {
		todo.Notes = *req.Notes
	}
	if req.ContextID != nil {
		// Verify context
		var context models.Context
		if err := tx.Where("id = ? AND user_id = ?", *req.ContextID, userID).First(&context).Error; err != nil {
			tx.Rollback()
			return nil, fmt.Errorf("context not found")
		}
		todo.ContextID = *req.ContextID
	}
	if req.ProjectID != nil {
		// Verify project
		var project models.Project
		if err := tx.Where("id = ? AND user_id = ?", *req.ProjectID, userID).First(&project).Error; err != nil {
			tx.Rollback()
			return nil, fmt.Errorf("project not found")
		}
		todo.ProjectID = req.ProjectID
	}
	if req.DueDate != nil {
		todo.DueDate = req.DueDate
	}
	if req.ShowFrom != nil {
		todo.ShowFrom = req.ShowFrom
	}
	if req.Starred != nil {
		todo.Starred = *req.Starred
	}

	if err := tx.Save(&todo).Error; err != nil {
		tx.Rollback()
		return nil, err
	}

	// Handle tags
	if req.TagNames != nil {
		tagService := NewTagService()
		if err := tagService.SetTodoTags(tx, userID, todo.ID, req.TagNames); err != nil {
			tx.Rollback()
			return nil, err
		}
	}

	if err := tx.Commit().Error; err != nil {
		return nil, err
	}

	// Reload with associations
	return s.GetTodo(userID, todoID)
}

// DeleteTodo deletes a todo
func (s *TodoService) DeleteTodo(userID, todoID uint) error {
	todo, err := s.GetTodo(userID, todoID)
	if err != nil {
		return err
	}

	return database.DB.Delete(&todo).Error
}

// CompleteTodo marks a todo as completed
func (s *TodoService) CompleteTodo(userID, todoID uint) (*models.Todo, error) {
	todo, err := s.GetTodo(userID, todoID)
	if err != nil {
		return nil, err
	}

	if err := todo.Complete(); err != nil {
		return nil, err
	}

	tx := database.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	if err := tx.Save(&todo).Error; err != nil {
		tx.Rollback()
		return nil, err
	}

	// Unblock any pending successors
	if err := s.checkAndUnblockSuccessors(tx, todoID); err != nil {
		tx.Rollback()
		return nil, err
	}

	if err := tx.Commit().Error; err != nil {
		return nil, err
	}

	return s.GetTodo(userID, todoID)
}

// ActivateTodo marks a todo as active
func (s *TodoService) ActivateTodo(userID, todoID uint) (*models.Todo, error) {
	todo, err := s.GetTodo(userID, todoID)
	if err != nil {
		return nil, err
	}

	// Check if there are incomplete predecessors
	hasIncompletePredecessors, err := s.hasIncompletePredecessors(todoID)
	if err != nil {
		return nil, err
	}
	if hasIncompletePredecessors {
		return nil, fmt.Errorf("cannot activate todo with incomplete predecessors")
	}

	if err := todo.Activate(); err != nil {
		return nil, err
	}

	if err := database.DB.Save(&todo).Error; err != nil {
		return nil, err
	}

	return s.GetTodo(userID, todoID)
}

// DeferTodo marks a todo as deferred
func (s *TodoService) DeferTodo(userID, todoID uint, showFrom time.Time) (*models.Todo, error) {
	todo, err := s.GetTodo(userID, todoID)
	if err != nil {
		return nil, err
	}

	if err := todo.Defer(showFrom); err != nil {
		return nil, err
	}

	if err := database.DB.Save(&todo).Error; err != nil {
		return nil, err
	}

	return s.GetTodo(userID, todoID)
}

// AddDependency adds a dependency between two todos
func (s *TodoService) AddDependency(userID, predecessorID, successorID uint) error {
	// Verify both todos belong to user
	if _, err := s.GetTodo(userID, predecessorID); err != nil {
		return fmt.Errorf("predecessor not found")
	}
	if _, err := s.GetTodo(userID, successorID); err != nil {
		return fmt.Errorf("successor not found")
	}

	// Check for circular dependencies
	if err := s.checkCircularDependency(predecessorID, successorID); err != nil {
		return err
	}

	// Create dependency
	dependency := models.Dependency{
		PredecessorID:    predecessorID,
		SuccessorID:      successorID,
		RelationshipType: models.DependencyTypeBlocks,
	}

	if err := database.DB.Create(&dependency).Error; err != nil {
		return err
	}

	// Block the successor if predecessor is not complete
	successor, _ := s.GetTodo(userID, successorID)
	predecessor, _ := s.GetTodo(userID, predecessorID)

	if !predecessor.IsCompleted() && !successor.IsPending() {
		successor.Block()
		database.DB.Save(successor)
	}

	return nil
}

// RemoveDependency removes a dependency
func (s *TodoService) RemoveDependency(userID, predecessorID, successorID uint) error {
	// Verify both todos belong to user
	if _, err := s.GetTodo(userID, predecessorID); err != nil {
		return err
	}
	if _, err := s.GetTodo(userID, successorID); err != nil {
		return err
	}

	if err := database.DB.
		Where("predecessor_id = ? AND successor_id = ?", predecessorID, successorID).
		Delete(&models.Dependency{}).Error; err != nil {
		return err
	}

	// Check if successor should be unblocked
	s.checkAndUnblockSuccessors(database.DB, successorID)

	return nil
}

// Helper functions

func (s *TodoService) hasIncompletePredecessors(todoID uint) (bool, error) {
	var count int64
	err := database.DB.Model(&models.Dependency{}).
		Joins("JOIN todos ON todos.id = dependencies.predecessor_id").
		Where("dependencies.successor_id = ? AND todos.state != ?", todoID, models.TodoStateCompleted).
		Count(&count).Error

	return count > 0, err
}

func (s *TodoService) checkAndUnblockSuccessors(tx *gorm.DB, todoID uint) error {
	var successors []models.Todo

	// Get all successors
	if err := tx.
		Joins("JOIN dependencies ON dependencies.successor_id = todos.id").
		Where("dependencies.predecessor_id = ? AND todos.state = ?", todoID, models.TodoStatePending).
		Find(&successors).Error; err != nil {
		return err
	}

	// For each successor, check if all predecessors are complete
	for _, successor := range successors {
		hasIncompletePredecessors, err := s.hasIncompletePredecessors(successor.ID)
		if err != nil {
			return err
		}

		if !hasIncompletePredecessors {
			successor.Unblock()
			if err := tx.Save(&successor).Error; err != nil {
				return err
			}
		}
	}

	return nil
}

func (s *TodoService) checkCircularDependency(predecessorID, successorID uint) error {
	// Simple check: ensure successor is not already a predecessor of the predecessor
	visited := make(map[uint]bool)
	return s.dfsCheckCircular(successorID, predecessorID, visited)
}

func (s *TodoService) dfsCheckCircular(currentID, targetID uint, visited map[uint]bool) error {
	if currentID == targetID {
		return fmt.Errorf("circular dependency detected")
	}

	if visited[currentID] {
		return nil
	}

	visited[currentID] = true

	var successors []models.Dependency
	if err := database.DB.Where("predecessor_id = ?", currentID).Find(&successors).Error; err != nil {
		return err
	}

	for _, dep := range successors {
		if err := s.dfsCheckCircular(dep.SuccessorID, targetID, visited); err != nil {
			return err
		}
	}

	return nil
}
