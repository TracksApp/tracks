package models

import (
	"time"

	"gorm.io/gorm"
)

// ContextState represents the state of a context
type ContextState string

const (
	ContextStateActive ContextState = "active"
	ContextStateHidden ContextState = "hidden"
	ContextStateClosed ContextState = "closed"
)

// Context represents a GTD context (e.g., @home, @work, @phone)
type Context struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	UserID    uint           `gorm:"not null;index" json:"user_id"`
	Name      string         `gorm:"not null;size:255" json:"name"`
	Position  int            `gorm:"default:1" json:"position"`
	State     ContextState   `gorm:"type:varchar(20);default:'active'" json:"state"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	// Associations
	User           User            `gorm:"foreignKey:UserID" json:"-"`
	Todos          []Todo          `gorm:"foreignKey:ContextID" json:"todos,omitempty"`
	RecurringTodos []RecurringTodo `gorm:"foreignKey:ContextID" json:"recurring_todos,omitempty"`
}

// BeforeCreate sets default values
func (c *Context) BeforeCreate(tx *gorm.DB) error {
	if c.State == "" {
		c.State = ContextStateActive
	}
	if c.Position == 0 {
		c.Position = 1
	}
	return nil
}

// IsActive returns true if the context is active
func (c *Context) IsActive() bool {
	return c.State == ContextStateActive
}

// IsHidden returns true if the context is hidden
func (c *Context) IsHidden() bool {
	return c.State == ContextStateHidden
}

// IsClosed returns true if the context is closed
func (c *Context) IsClosed() bool {
	return c.State == ContextStateClosed
}

// Hide sets the context state to hidden
func (c *Context) Hide() {
	c.State = ContextStateHidden
}

// Activate sets the context state to active
func (c *Context) Activate() {
	c.State = ContextStateActive
}

// Close sets the context state to closed
func (c *Context) Close() {
	c.State = ContextStateClosed
}
