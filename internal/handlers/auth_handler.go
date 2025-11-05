package handlers

import (
	"net/http"

	"github.com/TracksApp/tracks/internal/middleware"
	"github.com/TracksApp/tracks/internal/services"
	"github.com/gin-gonic/gin"
)

// AuthHandler handles authentication endpoints
type AuthHandler struct {
	authService *services.AuthService
}

// NewAuthHandler creates a new AuthHandler
func NewAuthHandler(authService *services.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
	}
}

// Login handles POST /api/login
func (h *AuthHandler) Login(c *gin.Context) {
	var req services.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := h.authService.Login(req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	// Set cookie
	c.SetCookie("tracks_token", resp.Token, 60*60*24*7, "/", "", false, true)

	c.JSON(http.StatusOK, resp)
}

// Register handles POST /api/register
func (h *AuthHandler) Register(c *gin.Context) {
	var req services.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := h.authService.Register(req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Set cookie
	c.SetCookie("tracks_token", resp.Token, 60*60*24*7, "/", "", false, true)

	c.JSON(http.StatusCreated, resp)
}

// Logout handles POST /api/logout
func (h *AuthHandler) Logout(c *gin.Context) {
	// Clear cookie
	c.SetCookie("tracks_token", "", -1, "/", "", false, true)
	c.JSON(http.StatusOK, gin.H{"message": "Logged out successfully"})
}

// Me handles GET /api/me
func (h *AuthHandler) Me(c *gin.Context) {
	user, err := middleware.GetCurrentUser(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	c.JSON(http.StatusOK, user)
}

// RefreshToken handles POST /api/refresh-token
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	user, err := middleware.GetCurrentUser(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	token, err := h.authService.RefreshToken(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to refresh token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}
