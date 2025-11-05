package models

import (
	"time"

	"gorm.io/gorm"
)

// Note represents a note attached to a project
type Note struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	UserID    uint           `gorm:"not null;index" json:"user_id"`
	ProjectID uint           `gorm:"not null;index" json:"project_id"`
	Body      string         `gorm:"type:text;not null" json:"body"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	// Associations
	User    User    `gorm:"foreignKey:UserID" json:"-"`
	Project Project `gorm:"foreignKey:ProjectID" json:"project,omitempty"`
}
