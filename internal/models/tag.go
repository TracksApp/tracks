package models

import (
	"time"

	"gorm.io/gorm"
)

// Tag represents a label that can be attached to todos and recurring todos
type Tag struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	UserID    uint           `gorm:"not null;index" json:"user_id"`
	Name      string         `gorm:"not null;size:255;index" json:"name"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	// Associations
	User     User      `gorm:"foreignKey:UserID" json:"-"`
	Taggings []Tagging `gorm:"foreignKey:TagID" json:"-"`
}

// Tagging represents the polymorphic join between tags and taggable entities
type Tagging struct {
	ID           uint      `gorm:"primaryKey" json:"id"`
	TagID        uint      `gorm:"not null;index" json:"tag_id"`
	TaggableID   uint      `gorm:"not null;index" json:"taggable_id"`
	TaggableType string    `gorm:"not null;size:255;index" json:"taggable_type"`
	CreatedAt    time.Time `json:"created_at"`

	// Associations
	Tag Tag `gorm:"foreignKey:TagID" json:"tag,omitempty"`
}
