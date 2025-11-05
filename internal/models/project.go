package models

import (
	"time"

	"gorm.io/gorm"
)

// ProjectState represents the state of a project
type ProjectState string

const (
	ProjectStateActive    ProjectState = "active"
	ProjectStateHidden    ProjectState = "hidden"
	ProjectStateCompleted ProjectState = "completed"
)

// Project represents a GTD project
type Project struct {
	ID               uint           `gorm:"primaryKey" json:"id"`
	UserID           uint           `gorm:"not null;index" json:"user_id"`
	Name             string         `gorm:"not null;size:255" json:"name"`
	Description      string         `gorm:"type:text" json:"description"`
	Position         int            `gorm:"default:1" json:"position"`
	State            ProjectState   `gorm:"type:varchar(20);default:'active'" json:"state"`
	DefaultContextID *uint          `json:"default_context_id"`
	DefaultTags      string         `gorm:"type:text" json:"default_tags"`
	CompletedAt      *time.Time     `json:"completed_at"`
	LastReviewedAt   *time.Time     `json:"last_reviewed_at"`
	CreatedAt        time.Time      `json:"created_at"`
	UpdatedAt        time.Time      `json:"updated_at"`
	DeletedAt        gorm.DeletedAt `gorm:"index" json:"-"`

	// Associations
	User           User            `gorm:"foreignKey:UserID" json:"-"`
	DefaultContext *Context        `gorm:"foreignKey:DefaultContextID" json:"default_context,omitempty"`
	Todos          []Todo          `gorm:"foreignKey:ProjectID" json:"todos,omitempty"`
	RecurringTodos []RecurringTodo `gorm:"foreignKey:ProjectID" json:"recurring_todos,omitempty"`
	Notes          []Note          `gorm:"foreignKey:ProjectID" json:"notes,omitempty"`
}

// BeforeCreate sets default values
func (p *Project) BeforeCreate(tx *gorm.DB) error {
	if p.State == "" {
		p.State = ProjectStateActive
	}
	if p.Position == 0 {
		p.Position = 1
	}
	return nil
}

// IsActive returns true if the project is active
func (p *Project) IsActive() bool {
	return p.State == ProjectStateActive
}

// IsHidden returns true if the project is hidden
func (p *Project) IsHidden() bool {
	return p.State == ProjectStateHidden
}

// IsCompleted returns true if the project is completed
func (p *Project) IsCompleted() bool {
	return p.State == ProjectStateCompleted
}

// Hide sets the project state to hidden
func (p *Project) Hide() {
	p.State = ProjectStateHidden
}

// Activate sets the project state to active
func (p *Project) Activate() {
	p.State = ProjectStateActive
}

// Complete sets the project state to completed
func (p *Project) Complete() {
	now := time.Now()
	p.State = ProjectStateCompleted
	p.CompletedAt = &now
}

// MarkReviewed updates the last_reviewed_at timestamp
func (p *Project) MarkReviewed() {
	now := time.Now()
	p.LastReviewedAt = &now
}
