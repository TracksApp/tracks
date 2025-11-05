package middleware

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/TracksApp/tracks/internal/database"
	"github.com/TracksApp/tracks/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

// Claims represents the JWT claims
type Claims struct {
	UserID uint   `json:"user_id"`
	Login  string `json:"login"`
	jwt.RegisteredClaims
}

// AuthMiddleware validates JWT tokens and sets the current user
func AuthMiddleware(jwtSecret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Try to get token from Authorization header
		authHeader := c.GetHeader("Authorization")
		var tokenString string

		if authHeader != "" {
			// Bearer token
			parts := strings.Split(authHeader, " ")
			if len(parts) == 2 && parts[0] == "Bearer" {
				tokenString = parts[1]
			}
		}

		// If no Bearer token, try cookie
		if tokenString == "" {
			cookie, err := c.Cookie("tracks_token")
			if err == nil {
				tokenString = cookie
			}
		}

		// If still no token, try query parameter (for feed tokens)
		if tokenString == "" {
			tokenString = c.Query("token")
		}

		if tokenString == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "No authentication token provided"})
			c.Abort()
			return
		}

		// Parse and validate token
		token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return []byte(jwtSecret), nil
		})

		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			c.Abort()
			return
		}

		claims, ok := token.Claims.(*Claims)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token claims"})
			c.Abort()
			return
		}

		// Load user from database
		var user models.User
		if err := database.DB.First(&user, claims.UserID).Error; err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
			c.Abort()
			return
		}

		// Set user in context
		c.Set("user", &user)
		c.Set("user_id", user.ID)

		c.Next()
	}
}

// OptionalAuthMiddleware attempts to authenticate but doesn't fail if no token
func OptionalAuthMiddleware(jwtSecret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		var tokenString string

		if authHeader != "" {
			parts := strings.Split(authHeader, " ")
			if len(parts) == 2 && parts[0] == "Bearer" {
				tokenString = parts[1]
			}
		}

		if tokenString == "" {
			cookie, err := c.Cookie("tracks_token")
			if err == nil {
				tokenString = cookie
			}
		}

		if tokenString != "" {
			token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
				return []byte(jwtSecret), nil
			})

			if err == nil && token.Valid {
				if claims, ok := token.Claims.(*Claims); ok {
					var user models.User
					if err := database.DB.First(&user, claims.UserID).Error; err == nil {
						c.Set("user", &user)
						c.Set("user_id", user.ID)
					}
				}
			}
		}

		c.Next()
	}
}

// AdminMiddleware ensures the user is an admin
func AdminMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		userInterface, exists := c.Get("user")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
			c.Abort()
			return
		}

		user, ok := userInterface.(*models.User)
		if !ok || !user.IsAdmin {
			c.JSON(http.StatusForbidden, gin.H{"error": "Admin access required"})
			c.Abort()
			return
		}

		c.Next()
	}
}

// GetCurrentUser retrieves the current user from the context
func GetCurrentUser(c *gin.Context) (*models.User, error) {
	userInterface, exists := c.Get("user")
	if !exists {
		return nil, fmt.Errorf("user not found in context")
	}

	user, ok := userInterface.(*models.User)
	if !ok {
		return nil, fmt.Errorf("invalid user type in context")
	}

	return user, nil
}

// GetCurrentUserID retrieves the current user ID from the context
func GetCurrentUserID(c *gin.Context) (uint, error) {
	userIDInterface, exists := c.Get("user_id")
	if !exists {
		return 0, fmt.Errorf("user ID not found in context")
	}

	userID, ok := userIDInterface.(uint)
	if !ok {
		return 0, fmt.Errorf("invalid user ID type in context")
	}

	return userID, nil
}
