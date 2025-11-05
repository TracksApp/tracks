package services

import (
	"errors"
	"fmt"
	"time"

	"github.com/TracksApp/tracks/internal/database"
	"github.com/TracksApp/tracks/internal/models"
	"gorm.io/gorm"
)

// ProjectService handles project business logic
type ProjectService struct{}

// NewProjectService creates a new ProjectService
func NewProjectService() *ProjectService {
	return &ProjectService{}
}

// CreateProjectRequest represents a project creation request
type CreateProjectRequest struct {
	Name             string `json:"name" binding:"required"`
	Description      string `json:"description"`
	DefaultContextID *uint  `json:"default_context_id"`
	DefaultTags      string `json:"default_tags"`
}

// UpdateProjectRequest represents a project update request
type UpdateProjectRequest struct {
	Name             *string `json:"name"`
	Description      *string `json:"description"`
	DefaultContextID *uint   `json:"default_context_id"`
	DefaultTags      *string `json:"default_tags"`
	State            *string `json:"state"`
}

// GetProjects returns all projects for a user
func (s *ProjectService) GetProjects(userID uint, state models.ProjectState) ([]models.Project, error) {
	var projects []models.Project

	query := database.DB.Where("user_id = ?", userID)

	if state != "" {
		query = query.Where("state = ?", state)
	}

	if err := query.
		Preload("DefaultContext").
		Order("position ASC, name ASC").
		Find(&projects).Error; err != nil {
		return nil, err
	}

	return projects, nil
}

// GetProject returns a single project by ID
func (s *ProjectService) GetProject(userID, projectID uint) (*models.Project, error) {
	var project models.Project

	if err := database.DB.
		Where("id = ? AND user_id = ?", projectID, userID).
		Preload("DefaultContext").
		Preload("Todos").
		Preload("Notes").
		First(&project).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("project not found")
		}
		return nil, err
	}

	return &project, nil
}

// CreateProject creates a new project
func (s *ProjectService) CreateProject(userID uint, req CreateProjectRequest) (*models.Project, error) {
	// Verify default context if provided
	if req.DefaultContextID != nil {
		var context models.Context
		if err := database.DB.Where("id = ? AND user_id = ?", *req.DefaultContextID, userID).First(&context).Error; err != nil {
			return nil, fmt.Errorf("default context not found")
		}
	}

	project := models.Project{
		UserID:           userID,
		Name:             req.Name,
		Description:      req.Description,
		DefaultContextID: req.DefaultContextID,
		DefaultTags:      req.DefaultTags,
		State:            models.ProjectStateActive,
	}

	if err := database.DB.Create(&project).Error; err != nil {
		return nil, err
	}

	return s.GetProject(userID, project.ID)
}

// UpdateProject updates a project
func (s *ProjectService) UpdateProject(userID, projectID uint, req UpdateProjectRequest) (*models.Project, error) {
	project, err := s.GetProject(userID, projectID)
	if err != nil {
		return nil, err
	}

	if req.Name != nil {
		project.Name = *req.Name
	}
	if req.Description != nil {
		project.Description = *req.Description
	}
	if req.DefaultContextID != nil {
		// Verify context
		var context models.Context
		if err := database.DB.Where("id = ? AND user_id = ?", *req.DefaultContextID, userID).First(&context).Error; err != nil {
			return nil, fmt.Errorf("default context not found")
		}
		project.DefaultContextID = req.DefaultContextID
	}
	if req.DefaultTags != nil {
		project.DefaultTags = *req.DefaultTags
	}
	if req.State != nil {
		project.State = models.ProjectState(*req.State)
	}

	if err := database.DB.Save(&project).Error; err != nil {
		return nil, err
	}

	return s.GetProject(userID, projectID)
}

// DeleteProject deletes a project
func (s *ProjectService) DeleteProject(userID, projectID uint) error {
	project, err := s.GetProject(userID, projectID)
	if err != nil {
		return err
	}

	return database.DB.Delete(&project).Error
}

// CompleteProject marks a project as completed
func (s *ProjectService) CompleteProject(userID, projectID uint) (*models.Project, error) {
	project, err := s.GetProject(userID, projectID)
	if err != nil {
		return nil, err
	}

	project.Complete()

	if err := database.DB.Save(&project).Error; err != nil {
		return nil, err
	}

	return s.GetProject(userID, projectID)
}

// ActivateProject marks a project as active
func (s *ProjectService) ActivateProject(userID, projectID uint) (*models.Project, error) {
	project, err := s.GetProject(userID, projectID)
	if err != nil {
		return nil, err
	}

	project.Activate()

	if err := database.DB.Save(&project).Error; err != nil {
		return nil, err
	}

	return s.GetProject(userID, projectID)
}

// HideProject marks a project as hidden
func (s *ProjectService) HideProject(userID, projectID uint) (*models.Project, error) {
	project, err := s.GetProject(userID, projectID)
	if err != nil {
		return nil, err
	}

	project.Hide()

	if err := database.DB.Save(&project).Error; err != nil {
		return nil, err
	}

	return s.GetProject(userID, projectID)
}

// MarkProjectReviewed updates the last_reviewed_at timestamp
func (s *ProjectService) MarkProjectReviewed(userID, projectID uint) (*models.Project, error) {
	project, err := s.GetProject(userID, projectID)
	if err != nil {
		return nil, err
	}

	project.MarkReviewed()

	if err := database.DB.Save(&project).Error; err != nil {
		return nil, err
	}

	return s.GetProject(userID, projectID)
}

// GetProjectStats returns statistics for a project
func (s *ProjectService) GetProjectStats(userID, projectID uint) (map[string]interface{}, error) {
	project, err := s.GetProject(userID, projectID)
	if err != nil {
		return nil, err
	}

	stats := make(map[string]interface{})

	// Count todos by state
	var activeTodos, completedTodos, deferredTodos, pendingTodos int64

	database.DB.Model(&models.Todo{}).
		Where("project_id = ? AND state = ?", projectID, models.TodoStateActive).
		Count(&activeTodos)

	database.DB.Model(&models.Todo{}).
		Where("project_id = ? AND state = ?", projectID, models.TodoStateCompleted).
		Count(&completedTodos)

	database.DB.Model(&models.Todo{}).
		Where("project_id = ? AND state = ?", projectID, models.TodoStateDeferred).
		Count(&deferredTodos)

	database.DB.Model(&models.Todo{}).
		Where("project_id = ? AND state = ?", projectID, models.TodoStatePending).
		Count(&pendingTodos)

	stats["project"] = project
	stats["active_todos"] = activeTodos
	stats["completed_todos"] = completedTodos
	stats["deferred_todos"] = deferredTodos
	stats["pending_todos"] = pendingTodos
	stats["total_todos"] = activeTodos + completedTodos + deferredTodos + pendingTodos
	stats["is_stalled"] = activeTodos == 0 && (deferredTodos > 0 || pendingTodos > 0)
	stats["is_blocked"] = activeTodos == 0 && (deferredTodos > 0 || pendingTodos > 0) && completedTodos == 0

	// Days since last review
	if project.LastReviewedAt != nil {
		daysSinceReview := int(time.Since(*project.LastReviewedAt).Hours() / 24)
		stats["days_since_review"] = daysSinceReview
	} else {
		stats["days_since_review"] = nil
	}

	return stats, nil
}
