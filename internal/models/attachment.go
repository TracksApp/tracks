package models

import (
	"time"

	"gorm.io/gorm"
)

// Attachment represents a file attached to a todo
type Attachment struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	TodoID          uint           `gorm:"not null;index" json:"todo_id"`
	FileName        string         `gorm:"size:255;not null" json:"file_name"`
	ContentType     string         `gorm:"size:255" json:"content_type"`
	FileSize        int64          `json:"file_size"`
	FilePath        string         `gorm:"size:500" json:"file_path"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`

	// Associations
	Todo Todo `gorm:"foreignKey:TodoID" json:"-"`
}
