package handlers

import (
	"net/http"
	"strconv"

	"github.com/TracksApp/tracks/internal/middleware"
	"github.com/TracksApp/tracks/internal/models"
	"github.com/TracksApp/tracks/internal/services"
	"github.com/gin-gonic/gin"
)

// ContextHandler handles context endpoints
type ContextHandler struct {
	contextService *services.ContextService
}

// NewContextHandler creates a new ContextHandler
func NewContextHandler(contextService *services.ContextService) *ContextHandler {
	return &ContextHandler{
		contextService: contextService,
	}
}

// ListContexts handles GET /api/contexts
func (h *ContextHandler) ListContexts(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	state := models.ContextState(c.Query("state"))
	contexts, err := h.contextService.GetContexts(userID, state)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, contexts)
}

// GetContext handles GET /api/contexts/:id
func (h *ContextHandler) GetContext(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	contextID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid context ID"})
		return
	}

	context, err := h.contextService.GetContext(userID, uint(contextID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, context)
}

// CreateContext handles POST /api/contexts
func (h *ContextHandler) CreateContext(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	var req services.CreateContextRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	context, err := h.contextService.CreateContext(userID, req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, context)
}

// UpdateContext handles PUT /api/contexts/:id
func (h *ContextHandler) UpdateContext(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	contextID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid context ID"})
		return
	}

	var req services.UpdateContextRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	context, err := h.contextService.UpdateContext(userID, uint(contextID), req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, context)
}

// DeleteContext handles DELETE /api/contexts/:id
func (h *ContextHandler) DeleteContext(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	contextID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid context ID"})
		return
	}

	if err := h.contextService.DeleteContext(userID, uint(contextID)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Context deleted"})
}

// HideContext handles POST /api/contexts/:id/hide
func (h *ContextHandler) HideContext(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	contextID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid context ID"})
		return
	}

	context, err := h.contextService.HideContext(userID, uint(contextID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, context)
}

// ActivateContext handles POST /api/contexts/:id/activate
func (h *ContextHandler) ActivateContext(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	contextID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid context ID"})
		return
	}

	context, err := h.contextService.ActivateContext(userID, uint(contextID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, context)
}

// CloseContext handles POST /api/contexts/:id/close
func (h *ContextHandler) CloseContext(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	contextID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid context ID"})
		return
	}

	context, err := h.contextService.CloseContext(userID, uint(contextID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, context)
}

// GetContextStats handles GET /api/contexts/:id/stats
func (h *ContextHandler) GetContextStats(c *gin.Context) {
	userID, err := middleware.GetCurrentUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Not authenticated"})
		return
	}

	contextID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid context ID"})
		return
	}

	stats, err := h.contextService.GetContextStats(userID, uint(contextID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, stats)
}
