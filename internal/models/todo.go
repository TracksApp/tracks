package models

import (
	"errors"
	"time"

	"gorm.io/gorm"
)

// TodoState represents the state of a todo
type TodoState string

const (
	TodoStateActive    TodoState = "active"
	TodoStateCompleted TodoState = "completed"
	TodoStateDeferred  TodoState = "deferred"
	TodoStatePending   TodoState = "pending"
)

// Todo represents a task/action item
type Todo struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	UserID          uint           `gorm:"not null;index" json:"user_id"`
	ContextID       uint           `gorm:"not null;index" json:"context_id"`
	ProjectID       *uint          `gorm:"index" json:"project_id"`
	RecurringTodoID *uint          `gorm:"index" json:"recurring_todo_id"`
	Description     string         `gorm:"not null;size:300" json:"description"`
	Notes           string         `gorm:"type:text" json:"notes"`
	State           TodoState      `gorm:"type:varchar(20);default:'active';index" json:"state"`
	DueDate         *time.Time     `json:"due_date"`
	ShowFrom        *time.Time     `json:"show_from"`
	CompletedAt     *time.Time     `json:"completed_at"`
	Starred         bool           `gorm:"default:false" json:"starred"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`

	// Associations
	User          User          `gorm:"foreignKey:UserID" json:"-"`
	Context       Context       `gorm:"foreignKey:ContextID" json:"context,omitempty"`
	Project       *Project      `gorm:"foreignKey:ProjectID" json:"project,omitempty"`
	RecurringTodo *RecurringTodo `gorm:"foreignKey:RecurringTodoID" json:"recurring_todo,omitempty"`
	Taggings      []Tagging     `gorm:"polymorphic:Taggable" json:"-"`
	Tags          []Tag         `gorm:"many2many:taggings;foreignKey:ID;joinForeignKey:TaggableID;References:ID;joinReferences:TagID" json:"tags,omitempty"`
	Attachments   []Attachment  `gorm:"foreignKey:TodoID" json:"attachments,omitempty"`

	// Dependencies
	Predecessors []Dependency `gorm:"foreignKey:SuccessorID" json:"predecessors,omitempty"`
	Successors   []Dependency `gorm:"foreignKey:PredecessorID" json:"successors,omitempty"`
}

// BeforeCreate sets default values
func (t *Todo) BeforeCreate(tx *gorm.DB) error {
	if t.State == "" {
		t.State = TodoStateActive
	}
	return nil
}

// IsActive returns true if the todo is active
func (t *Todo) IsActive() bool {
	return t.State == TodoStateActive
}

// IsCompleted returns true if the todo is completed
func (t *Todo) IsCompleted() bool {
	return t.State == TodoStateCompleted
}

// IsDeferred returns true if the todo is deferred
func (t *Todo) IsDeferred() bool {
	return t.State == TodoStateDeferred
}

// IsPending returns true if the todo is pending (blocked)
func (t *Todo) IsPending() bool {
	return t.State == TodoStatePending
}

// Complete transitions the todo to completed state
func (t *Todo) Complete() error {
	if t.IsCompleted() {
		return errors.New("todo is already completed")
	}

	now := time.Now()
	t.State = TodoStateCompleted
	t.CompletedAt = &now

	return nil
}

// Activate transitions the todo to active state
func (t *Todo) Activate() error {
	if t.IsActive() {
		return errors.New("todo is already active")
	}

	// Can't activate if it has incomplete predecessors
	// This check should be done by the service layer

	t.State = TodoStateActive
	t.CompletedAt = nil

	return nil
}

// Defer transitions the todo to deferred state
func (t *Todo) Defer(showFrom time.Time) error {
	if !t.IsActive() {
		return errors.New("can only defer active todos")
	}

	t.State = TodoStateDeferred
	t.ShowFrom = &showFrom

	return nil
}

// Block transitions the todo to pending state
func (t *Todo) Block() error {
	if t.IsCompleted() {
		return errors.New("cannot block completed todo")
	}

	t.State = TodoStatePending

	return nil
}

// Unblock transitions the todo from pending to active
func (t *Todo) Unblock() error {
	if !t.IsPending() {
		return errors.New("todo is not pending")
	}

	t.State = TodoStateActive

	return nil
}

// IsDue returns true if the todo has a due date that has passed
func (t *Todo) IsDue() bool {
	if t.DueDate == nil {
		return false
	}
	return t.DueDate.Before(time.Now())
}

// IsOverdue returns true if the todo is active and past due
func (t *Todo) IsOverdue() bool {
	return t.IsActive() && t.IsDue()
}

// ShouldShow returns true if the todo should be displayed (not deferred or show_from has passed)
func (t *Todo) ShouldShow() bool {
	if t.ShowFrom == nil {
		return true
	}
	return t.ShowFrom.Before(time.Now()) || t.ShowFrom.Equal(time.Now())
}

// IsStale returns true if the todo is old based on the staleness threshold
func (t *Todo) IsStale(stalenessThresholdDays int) bool {
	if t.IsCompleted() {
		return false
	}

	threshold := time.Now().AddDate(0, 0, -stalenessThresholdDays)
	return t.CreatedAt.Before(threshold)
}
