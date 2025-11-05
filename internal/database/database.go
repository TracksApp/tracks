package database

import (
	"fmt"
	"log"
	"time"

	"github.com/TracksApp/tracks/internal/config"
	"github.com/TracksApp/tracks/internal/models"
	"gorm.io/driver/mysql"
	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// DB is the global database instance
var DB *gorm.DB

// Initialize sets up the database connection
func Initialize(cfg *config.DatabaseConfig) error {
	var dialector gorm.Dialector

	switch cfg.Driver {
	case "sqlite":
		dialector = sqlite.Open(cfg.GetDSN())
	case "mysql":
		dialector = mysql.Open(cfg.GetDSN())
	case "postgres":
		dialector = postgres.Open(cfg.GetDSN())
	default:
		return fmt.Errorf("unsupported database driver: %s", cfg.Driver)
	}

	db, err := gorm.Open(dialector, &gorm.Config{
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
