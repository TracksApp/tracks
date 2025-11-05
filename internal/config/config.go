package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

// Config holds the application configuration
type Config struct {
	Server   ServerConfig
	Database DatabaseConfig
	Auth     AuthConfig
	App      AppConfig
}

// ServerConfig holds server-related configuration
type ServerConfig struct {
	Host string
	Port int
	Mode string // debug, release, test
}

// DatabaseConfig holds database-related configuration
type DatabaseConfig struct {
	Driver   string // sqlite, mysql, postgres
	Host     string
	Port     int
	Name     string
	User     string
	Password string
	SSLMode  string
}

// AuthConfig holds authentication-related configuration
type AuthConfig struct {
	JWTSecret     string
	TokenExpiry   int  // in hours
	SecureCookies bool
}

// AppConfig holds application-specific configuration
type AppConfig struct {
	Name             string
	TimeZone         string
	OpenSignups      bool
	AdminEmail       string
	SecretToken      string
	ForceSSL         bool
	UploadPath       string
	MaxUploadSizeMB  int64
}

// Load reads configuration from environment variables
func Load() (*Config, error) {
	// Try to load .env file if it exists
	_ = godotenv.Load()

	cfg := &Config{
		Server: ServerConfig{
			Host: getEnv("SERVER_HOST", "0.0.0.0"),
			Port: getEnvAsInt("SERVER_PORT", 3000),
			Mode: getEnv("GIN_MODE", "debug"),
		},
		Database: DatabaseConfig{
			Driver:   getEnv("DB_DRIVER", "sqlite"),
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnvAsInt("DB_PORT", 5432),
			Name:     getEnv("DB_NAME", "tracks.db"),
			User:     getEnv("DB_USER", ""),
			Password: getEnv("DB_PASSWORD", ""),
			SSLMode:  getEnv("DB_SSLMODE", "disable"),
		},
		Auth: AuthConfig{
			JWTSecret:     getEnv("JWT_SECRET", "change-me-in-production"),
			TokenExpiry:   getEnvAsInt("TOKEN_EXPIRY_HOURS", 24),
			SecureCookies: getEnvAsBool("SECURE_COOKIES", false),
		},
		App: AppConfig{
			Name:             getEnv("APP_NAME", "Tracks"),
			TimeZone:         getEnv("TZ", "UTC"),
			OpenSignups:      getEnvAsBool("OPEN_SIGNUPS", false),
			AdminEmail:       getEnv("ADMIN_EMAIL", ""),
			SecretToken:      getEnv("SECRET_TOKEN", "change-me-in-production"),
			ForceSSL:         getEnvAsBool("FORCE_SSL", false),
			UploadPath:       getEnv("UPLOAD_PATH", "./uploads"),
			MaxUploadSizeMB:  getEnvAsInt64("MAX_UPLOAD_SIZE_MB", 10),
		},
	}

	return cfg, nil
}

// GetDSN returns the database connection string
func (c *DatabaseConfig) GetDSN() string {
	switch c.Driver {
	case "sqlite":
		return c.Name
	case "mysql":
		return fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=True&loc=Local",
			c.User, c.Password, c.Host, c.Port, c.Name)
	case "postgres":
		return fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
			c.Host, c.Port, c.User, c.Password, c.Name, c.SSLMode)
	default:
		return ""
	}
}

// Helper functions

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	valueStr := getEnv(key, "")
	if value, err := strconv.Atoi(valueStr); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsInt64(key string, defaultValue int64) int64 {
	valueStr := getEnv(key, "")
	if value, err := strconv.ParseInt(valueStr, 10, 64); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsBool(key string, defaultValue bool) bool {
	valueStr := getEnv(key, "")
	if value, err := strconv.ParseBool(valueStr); err == nil {
		return value
	}
	return defaultValue
}
