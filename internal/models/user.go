package models

import (
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// AuthType represents the authentication scheme
type AuthType string

const (
	AuthTypeDatabase AuthType = "database"
	AuthTypeOpenID   AuthType = "openid"
	AuthTypeCAS      AuthType = "cas"
)

// User represents a user account
type User struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	Login           string         `gorm:"uniqueIndex;not null;size:80" json:"login"`
	CryptedPassword string         `gorm:"size:255" json:"-"`
	Token           string         `gorm:"uniqueIndex;size:255" json:"token,omitempty"`
	IsAdmin         bool           `gorm:"default:false" json:"is_admin"`
	FirstName       string         `gorm:"size:255" json:"first_name"`
	LastName        string         `gorm:"size:255" json:"last_name"`
	AuthType        AuthType       `gorm:"type:varchar(255);default:'database'" json:"auth_type"`
	OpenIDUrl       string         `gorm:"size:255" json:"open_id_url,omitempty"`
	RememberToken   string         `gorm:"size:255" json:"-"`
	RememberExpires *time.Time     `json:"-"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`

	// Associations
	Contexts       []Context       `gorm:"foreignKey:UserID" json:"contexts,omitempty"`
	Projects       []Project       `gorm:"foreignKey:UserID" json:"projects,omitempty"`
	Todos          []Todo          `gorm:"foreignKey:UserID" json:"todos,omitempty"`
	RecurringTodos []RecurringTodo `gorm:"foreignKey:UserID" json:"recurring_todos,omitempty"`
	Tags           []Tag           `gorm:"foreignKey:UserID" json:"tags,omitempty"`
	Notes          []Note          `gorm:"foreignKey:UserID" json:"notes,omitempty"`
	Preference     *Preference     `gorm:"foreignKey:UserID" json:"preference,omitempty"`
}

// SetPassword hashes and sets the user's password
func (u *User) SetPassword(password string) error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	u.CryptedPassword = string(hashedPassword)
	return nil
}

// CheckPassword verifies if the provided password matches the user's password
func (u *User) CheckPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(u.CryptedPassword), []byte(password))
	return err == nil
}

// BeforeCreate hook to set default values
func (u *User) BeforeCreate(tx *gorm.DB) error {
	if u.AuthType == "" {
		u.AuthType = AuthTypeDatabase
	}
	return nil
}
