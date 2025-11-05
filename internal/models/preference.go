package models

import (
	"time"

	"gorm.io/gorm"
)

// Preference represents user preferences and settings
type Preference struct {
	ID                      uint           `gorm:"primaryKey" json:"id"`
	UserID                  uint           `gorm:"uniqueIndex;not null" json:"user_id"`
	DateFormat              string         `gorm:"size:255;default:'%d/%m/%Y'" json:"date_format"`
	TimeZone                string         `gorm:"size:255;default:'UTC'" json:"time_zone"`
	WeekStartsOn            int            `gorm:"default:0" json:"week_starts_on"` // 0=Sunday, 1=Monday
	ShowNumberCompleted     int            `gorm:"default:5" json:"show_number_completed"`
	StalenessStartsInDays   int            `gorm:"default:14" json:"staleness_starts_in_days"`
	DueDateStyle            string         `gorm:"size:255;default:'due'" json:"due_date_style"`
	MobileItemsPerPage      int            `gorm:"default:6" json:"mobile_items_per_page"`
	RefreshInterval         int            `gorm:"default:0" json:"refresh_interval"`
	ShowProjectOnTodoLine   bool           `gorm:"default:true" json:"show_project_on_todo_line"`
	ShowContextOnTodoLine   bool           `gorm:"default:true" json:"show_context_on_todo_line"`
	ShowHiddenProjectsInSidebar bool       `gorm:"default:true" json:"show_hidden_projects_in_sidebar"`
	ShowHiddenContextsInSidebar bool       `gorm:"default:true" json:"show_hidden_contexts_in_sidebar"`
	ReviewPeriodInDays      int            `gorm:"default:28" json:"review_period_in_days"`
	Theme                   string         `gorm:"size:255;default:'light_blue'" json:"theme"`
	SmsEmail                string         `gorm:"size:255" json:"sms_email"`
	SmsContext              *uint          `json:"sms_context_id"`
	CreatedAt               time.Time      `json:"created_at"`
	UpdatedAt               time.Time      `json:"updated_at"`
	DeletedAt               gorm.DeletedAt `gorm:"index" json:"-"`

	// Associations
	User       User     `gorm:"foreignKey:UserID" json:"-"`
	SMSContext *Context `gorm:"foreignKey:SmsContext" json:"sms_context,omitempty"`
}

// BeforeCreate sets default values
func (p *Preference) BeforeCreate(tx *gorm.DB) error {
	if p.DateFormat == "" {
		p.DateFormat = "%d/%m/%Y"
	}
	if p.TimeZone == "" {
		p.TimeZone = "UTC"
	}
	if p.Theme == "" {
		p.Theme = "light_blue"
	}
	if p.ShowNumberCompleted == 0 {
		p.ShowNumberCompleted = 5
	}
	if p.StalenessStartsInDays == 0 {
		p.StalenessStartsInDays = 14
	}
	if p.MobileItemsPerPage == 0 {
		p.MobileItemsPerPage = 6
	}
	if p.ReviewPeriodInDays == 0 {
		p.ReviewPeriodInDays = 28
	}
	return nil
}
