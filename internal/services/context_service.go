package services

import (
	"errors"
	"fmt"

	"github.com/TracksApp/tracks/internal/database"
	"github.com/TracksApp/tracks/internal/models"
	"gorm.io/gorm"
)

// ContextService handles context business logic
type ContextService struct{}

// NewContextService creates a new ContextService
func NewContextService() *ContextService {
	return &ContextService{}
}

// CreateContextRequest represents a context creation request
type CreateContextRequest struct {
	Name string `json:"name" binding:"required"`
}

// UpdateContextRequest represents a context update request
type UpdateContextRequest struct {
	Name     *string `json:"name"`
	Position *int    `json:"position"`
	State    *string `json:"state"`
}

// GetContexts returns all contexts for a user
func (s *ContextService) GetContexts(userID uint, state models.ContextState) ([]models.Context, error) {
	var contexts []models.Context

	query := database.DB.Where("user_id = ?", userID)

	if state != "" {
		query = query.Where("state = ?", state)
	}

	if err := query.
		Order("position ASC, name ASC").
		Find(&contexts).Error; err != nil {
		return nil, err
	}

	return contexts, nil
}

// GetContext returns a single context by ID
func (s *ContextService) GetContext(userID, contextID uint) (*models.Context, error) {
	var context models.Context

	if err := database.DB.
		Where("id = ? AND user_id = ?", contextID, userID).
		First(&context).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("context not found")
		}
		return nil, err
	}

	return &context, nil
}

// CreateContext creates a new context
func (s *ContextService) CreateContext(userID uint, req CreateContextRequest) (*models.Context, error) {
	context := models.Context{
		UserID: userID,
		Name:   req.Name,
		State:  models.ContextStateActive,
	}

	if err := database.DB.Create(&context).Error; err != nil {
		return nil, err
	}

	return s.GetContext(userID, context.ID)
}

// UpdateContext updates a context
func (s *ContextService) UpdateContext(userID, contextID uint, req UpdateContextRequest) (*models.Context, error) {
	context, err := s.GetContext(userID, contextID)
	if err != nil {
		return nil, err
	}

	if req.Name != nil {
		context.Name = *req.Name
	}
	if req.Position != nil {
		context.Position = *req.Position
	}
	if req.State != nil {
		context.State = models.ContextState(*req.State)
	}

	if err := database.DB.Save(&context).Error; err != nil {
		return nil, err
	}

	return s.GetContext(userID, contextID)
}

// DeleteContext deletes a context
func (s *ContextService) DeleteContext(userID, contextID uint) error {
	context, err := s.GetContext(userID, contextID)
	if err != nil {
		return err
	}

	// Check if context has active todos
	var activeTodoCount int64
	database.DB.Model(&models.Todo{}).
		Where("context_id = ? AND state = ?", contextID, models.TodoStateActive).
		Count(&activeTodoCount)

	if activeTodoCount > 0 {
		return fmt.Errorf("cannot delete context with active todos")
	}

	return database.DB.Delete(&context).Error
}

// HideContext marks a context as hidden
func (s *ContextService) HideContext(userID, contextID uint) (*models.Context, error) {
	context, err := s.GetContext(userID, contextID)
	if err != nil {
		return nil, err
	}

	context.Hide()

	if err := database.DB.Save(&context).Error; err != nil {
		return nil, err
	}

	return s.GetContext(userID, contextID)
}

// ActivateContext marks a context as active
func (s *ContextService) ActivateContext(userID, contextID uint) (*models.Context, error) {
	context, err := s.GetContext(userID, contextID)
	if err != nil {
		return nil, err
	}

	context.Activate()

	if err := database.DB.Save(&context).Error; err != nil {
		return nil, err
	}

	return s.GetContext(userID, contextID)
}

// CloseContext marks a context as closed
func (s *ContextService) CloseContext(userID, contextID uint) (*models.Context, error) {
	context, err := s.GetContext(userID, contextID)
	if err != nil {
		return nil, err
	}

	// Check if context has active todos
	var activeTodoCount int64
	database.DB.Model(&models.Todo{}).
		Where("context_id = ? AND state = ?", contextID, models.TodoStateActive).
		Count(&activeTodoCount)

	if activeTodoCount > 0 {
		return nil, fmt.Errorf("cannot close context with active todos")
	}

	context.Close()

	if err := database.DB.Save(&context).Error; err != nil {
		return nil, err
	}

	return s.GetContext(userID, contextID)
}

// GetContextStats returns statistics for a context
func (s *ContextService) GetContextStats(userID, contextID uint) (map[string]interface{}, error) {
	context, err := s.GetContext(userID, contextID)
	if err != nil {
		return nil, err
	}

	stats := make(map[string]interface{})

	// Count todos by state
	var activeTodos, completedTodos, deferredTodos, pendingTodos int64

	database.DB.Model(&models.Todo{}).
		Where("context_id = ? AND state = ?", contextID, models.TodoStateActive).
		Count(&activeTodos)

	database.DB.Model(&models.Todo{}).
		Where("context_id = ? AND state = ?", contextID, models.TodoStateCompleted).
		Count(&completedTodos)

	database.DB.Model(&models.Todo{}).
		Where("context_id = ? AND state = ?", contextID, models.TodoStateDeferred).
		Count(&deferredTodos)

	database.DB.Model(&models.Todo{}).
		Where("context_id = ? AND state = ?", contextID, models.TodoStatePending).
		Count(&pendingTodos)

	stats["context"] = context
	stats["active_todos"] = activeTodos
	stats["completed_todos"] = completedTodos
	stats["deferred_todos"] = deferredTodos
	stats["pending_todos"] = pendingTodos
	stats["total_todos"] = activeTodos + completedTodos + deferredTodos + pendingTodos

	return stats, nil
}
