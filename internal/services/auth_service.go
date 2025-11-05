package services

import (
	"errors"
	"time"

	"github.com/TracksApp/tracks/internal/database"
	"github.com/TracksApp/tracks/internal/models"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// AuthService handles authentication logic
type AuthService struct {
	jwtSecret string
}

// NewAuthService creates a new AuthService
func NewAuthService(jwtSecret string) *AuthService {
	return &AuthService{
		jwtSecret: jwtSecret,
	}
}

// LoginRequest represents a login request
type LoginRequest struct {
	Login    string `json:"login" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// RegisterRequest represents a registration request
type RegisterRequest struct {
	Login     string `json:"login" binding:"required"`
	Password  string `json:"password" binding:"required"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
}

// CreateUserRequest represents an admin user creation request
type CreateUserRequest struct {
	Login     string `json:"login" binding:"required"`
	Password  string `json:"password" binding:"required"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	IsAdmin   bool   `json:"is_admin"`
}

// AuthResponse represents an authentication response
type AuthResponse struct {
	Token string       `json:"token"`
	User  *models.User `json:"user"`
}

// Login authenticates a user and returns a JWT token
func (s *AuthService) Login(req LoginRequest) (*AuthResponse, error) {
	var user models.User

	// Find user by login
	if err := database.DB.Where("login = ?", req.Login).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("invalid login or password")
		}
		return nil, err
	}

	// Check password
	if !user.CheckPassword(req.Password) {
		return nil, errors.New("invalid login or password")
	}

	// Generate token
	token, err := s.GenerateToken(&user)
	if err != nil {
		return nil, err
	}

	return &AuthResponse{
		Token: token,
		User:  &user,
	}, nil
}

// Register creates a new user account
func (s *AuthService) Register(req RegisterRequest) (*AuthResponse, error) {
	// Check if user already exists
	var existingUser models.User
	if err := database.DB.Where("login = ?", req.Login).First(&existingUser).Error; err == nil {
		return nil, errors.New("user already exists")
	}

	// Create new user
	user := models.User{
		Login:     req.Login,
		FirstName: req.FirstName,
		LastName:  req.LastName,
		AuthType:  models.AuthTypeDatabase,
		Token:     uuid.New().String(),
	}

	// Set password
	if err := user.SetPassword(req.Password); err != nil {
		return nil, err
	}

	// Save user
	if err := database.DB.Create(&user).Error; err != nil {
		return nil, err
	}

	// Create default preference
	preference := models.Preference{
		UserID: user.ID,
	}
	if err := database.DB.Create(&preference).Error; err != nil {
		return nil, err
	}

	// Generate token
	token, err := s.GenerateToken(&user)
	if err != nil {
		return nil, err
	}

	return &AuthResponse{
		Token: token,
		User:  &user,
	}, nil
}

// GenerateToken generates a JWT token for a user
func (s *AuthService) GenerateToken(user *models.User) (string, error) {
	claims := jwt.MapClaims{
		"user_id": user.ID,
		"login":   user.Login,
		"exp":     time.Now().Add(time.Hour * 24 * 7).Unix(), // 7 days
		"iat":     time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.jwtSecret))
}

// RefreshToken refreshes the user's API token
func (s *AuthService) RefreshToken(userID uint) (string, error) {
	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		return "", err
	}

	user.Token = uuid.New().String()
	if err := database.DB.Save(&user).Error; err != nil {
		return "", err
	}

	return user.Token, nil
}

// CreateUser creates a new user (admin only)
func (s *AuthService) CreateUser(req CreateUserRequest) (*models.User, error) {
	// Check if user already exists
	var existingUser models.User
	if err := database.DB.Where("login = ?", req.Login).First(&existingUser).Error; err == nil {
		return nil, errors.New("user already exists")
	}

	// Create new user
	user := models.User{
		Login:     req.Login,
		FirstName: req.FirstName,
		LastName:  req.LastName,
		IsAdmin:   req.IsAdmin,
		AuthType:  models.AuthTypeDatabase,
		Token:     uuid.New().String(),
	}

	// Set password
	if err := user.SetPassword(req.Password); err != nil {
		return nil, err
	}

	// Save user
	if err := database.DB.Create(&user).Error; err != nil {
		return nil, err
	}

	// Create default preference
	preference := models.Preference{
		UserID: user.ID,
	}
	if err := database.DB.Create(&preference).Error; err != nil {
		return nil, err
	}

	return &user, nil
}
