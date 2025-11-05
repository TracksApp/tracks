package models

import (
	"time"
)

// DependencyRelationshipType represents the type of dependency relationship
type DependencyRelationshipType string

const (
	DependencyTypeBlocks DependencyRelationshipType = "blocks" // Predecessor blocks successor
)

// Dependency represents a dependency relationship between todos
type Dependency struct {
	ID               uint                       `gorm:"primaryKey" json:"id"`
	PredecessorID    uint                       `gorm:"not null;index" json:"predecessor_id"`
	SuccessorID      uint                       `gorm:"not null;index" json:"successor_id"`
	RelationshipType DependencyRelationshipType `gorm:"type:varchar(20);default:'blocks'" json:"relationship_type"`
	CreatedAt        time.Time                  `json:"created_at"`

	// Associations
	Predecessor Todo `gorm:"foreignKey:PredecessorID" json:"predecessor,omitempty"`
	Successor   Todo `gorm:"foreignKey:SuccessorID" json:"successor,omitempty"`
}
