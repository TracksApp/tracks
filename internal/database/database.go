package database

import (
	"fmt"
	"log"
	"time"

	"github.com/TracksApp/tracks/internal/config"
	"github.com/TracksApp/tracks/internal/models"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// DB is the global database instance
var DB *gorm.DB

// Initialize sets up the database connection
func Initialize(cfg *config.DatabaseConfig) error {
	db, err := gorm.Open(sqlite.Open(cfg.Name), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
		NowFunc: func() time.Time {
			return time.Now().UTC()
		},
	})
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}

	// Set connection pool settings
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("failed to get database instance: %w", err)
	}

	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(time.Hour)

	DB = db

	log.Println("Database connection established")
	return nil
}

// AutoMigrate runs database migrations
func AutoMigrate() error {
	if DB == nil {
		return fmt.Errorf("database not initialized")
	}

	log.Println("Running database migrations...")

	err := DB.AutoMigrate(
		&models.User{},
		&models.Preference{},
		&models.Context{},
		&models.Project{},
		&models.Todo{},
		&models.RecurringTodo{},
		&models.Tag{},
		&models.Tagging{},
		&models.Dependency{},
		&models.Note{},
		&models.Attachment{},
	)

	if err != nil {
		return fmt.Errorf("failed to run migrations: %w", err)
	}

	log.Println("Database migrations completed")
	return nil
}

// Close closes the database connection
func Close() error {
	if DB == nil {
		return nil
	}

	sqlDB, err := DB.DB()
	if err != nil {
		return err
	}

	return sqlDB.Close()
}

// GetDB returns the database instance
func GetDB() *gorm.DB {
	return DB
}

// CreateDefaultAdmin creates a default admin user if no users exist
func CreateDefaultAdmin() error {
	if DB == nil {
		return fmt.Errorf("database not initialized")
	}

	// Check if any users exist
	var count int64
	if err := DB.Model(&models.User{}).Count(&count).Error; err != nil {
		return fmt.Errorf("failed to count users: %w", err)
	}

	// If users exist, don't create default admin
	if count > 0 {
		log.Println("Users already exist, skipping default admin creation")
		return nil
	}

	log.Println("Creating default admin user (login: admin, password: admin)")

	// Create default admin user
	admin := models.User{
		Login:     "admin",
		FirstName: "Admin",
		LastName:  "User",
		IsAdmin:   true,
		AuthType:  models.AuthTypeDatabase,
		Token:     "default-admin-token",
	}

	// Set password
	if err := admin.SetPassword("admin"); err != nil {
		return fmt.Errorf("failed to set admin password: %w", err)
	}

	// Save admin user
	if err := DB.Create(&admin).Error; err != nil {
		return fmt.Errorf("failed to create admin user: %w", err)
	}

	// Create default preference for admin
	preference := models.Preference{
		UserID: admin.ID,
	}
	if err := DB.Create(&preference).Error; err != nil {
		return fmt.Errorf("failed to create admin preference: %w", err)
	}

	log.Printf("Default admin user created successfully (ID: %d)", admin.ID)
	return nil
}
