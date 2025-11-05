package models

import (
	"time"

	"gorm.io/gorm"
)

// RecurrenceType represents the type of recurrence pattern
type RecurrenceType string

const (
	RecurrenceTypeDaily   RecurrenceType = "daily"
	RecurrenceTypeWeekly  RecurrenceType = "weekly"
	RecurrenceTypeMonthly RecurrenceType = "monthly"
	RecurrenceTypeYearly  RecurrenceType = "yearly"
)

// RecurringTodoState represents the state of a recurring todo
type RecurringTodoState string

const (
	RecurringTodoStateActive    RecurringTodoState = "active"
	RecurringTodoStateCompleted RecurringTodoState = "completed"
)

// RecurrenceSelector represents how monthly/yearly recurrence is calculated
type RecurrenceSelector string

const (
	RecurrenceSelectorDate      RecurrenceSelector = "date"      // e.g., 15th of month
	RecurrenceSelectorDayOfWeek RecurrenceSelector = "day_of_week" // e.g., 3rd Monday
)

// RecurringTodo represents a template for recurring tasks
type RecurringTodo struct {
	ID                  uint               `gorm:"primaryKey" json:"id"`
	UserID              uint               `gorm:"not null;index" json:"user_id"`
	ContextID           uint               `gorm:"not null;index" json:"context_id"`
	ProjectID           *uint              `gorm:"index" json:"project_id"`
	Description         string             `gorm:"not null;size:300" json:"description"`
	Notes               string             `gorm:"type:text" json:"notes"`
	State               RecurringTodoState `gorm:"type:varchar(20);default:'active'" json:"state"`
	RecurrenceType      RecurrenceType     `gorm:"type:varchar(20);not null" json:"recurrence_type"`
	RecurrenceSelector  RecurrenceSelector `gorm:"type:varchar(20)" json:"recurrence_selector"`
	EveryN              int                `gorm:"default:1" json:"every_n"` // Every N days/weeks/months/years
	StartFrom           time.Time          `json:"start_from"`
	EndsOn              *time.Time         `json:"ends_on"`
	OccurrencesCount    *int               `json:"occurrences_count"`     // Total occurrences to create
	NumberOfOccurrences int                `gorm:"default:0" json:"number_of_occurrences"` // Created so far
	Target              string             `gorm:"type:varchar(20)" json:"target"` // 'due_date' or 'show_from'

	// Weekly recurrence
	RecursOnMonday    bool `gorm:"default:false" json:"recurs_on_monday"`
	RecursOnTuesday   bool `gorm:"default:false" json:"recurs_on_tuesday"`
	RecursOnWednesday bool `gorm:"default:false" json:"recurs_on_wednesday"`
	RecursOnThursday  bool `gorm:"default:false" json:"recurs_on_thursday"`
	RecursOnFriday    bool `gorm:"default:false" json:"recurs_on_friday"`
	RecursOnSaturday  bool `gorm:"default:false" json:"recurs_on_saturday"`
	RecursOnSunday    bool `gorm:"default:false" json:"recurs_on_sunday"`

	// Daily recurrence
	OnlyWorkdays bool `gorm:"default:false" json:"only_workdays"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	// Associations
	User     User      `gorm:"foreignKey:UserID" json:"-"`
	Context  Context   `gorm:"foreignKey:ContextID" json:"context,omitempty"`
	Project  *Project  `gorm:"foreignKey:ProjectID" json:"project,omitempty"`
	Todos    []Todo    `gorm:"foreignKey:RecurringTodoID" json:"todos,omitempty"`
	Taggings []Tagging `gorm:"polymorphic:Taggable" json:"-"`
	Tags     []Tag     `gorm:"many2many:taggings;foreignKey:ID;joinForeignKey:TaggableID;References:ID;joinReferences:TagID" json:"tags,omitempty"`
}

// BeforeCreate sets default values
func (rt *RecurringTodo) BeforeCreate(tx *gorm.DB) error {
	if rt.State == "" {
		rt.State = RecurringTodoStateActive
	}
	if rt.EveryN == 0 {
		rt.EveryN = 1
	}
	if rt.Target == "" {
		rt.Target = "due_date"
	}
	return nil
}

// IsActive returns true if the recurring todo is active
func (rt *RecurringTodo) IsActive() bool {
	return rt.State == RecurringTodoStateActive
}

// IsCompleted returns true if the recurring todo is completed
func (rt *RecurringTodo) IsCompleted() bool {
	return rt.State == RecurringTodoStateCompleted
}

// Complete marks the recurring todo as completed
func (rt *RecurringTodo) Complete() {
	rt.State = RecurringTodoStateCompleted
}

// ShouldComplete returns true if the recurring todo has reached its end condition
func (rt *RecurringTodo) ShouldComplete() bool {
	// Check if ended by date
	if rt.EndsOn != nil && time.Now().After(*rt.EndsOn) {
		return true
	}

	// Check if ended by occurrence count
	if rt.OccurrencesCount != nil && rt.NumberOfOccurrences >= *rt.OccurrencesCount {
		return true
	}

	return false
}

// IncrementOccurrences increments the occurrence counter
func (rt *RecurringTodo) IncrementOccurrences() {
	rt.NumberOfOccurrences++
}
