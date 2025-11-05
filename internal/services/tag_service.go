package services

import (
	"github.com/TracksApp/tracks/internal/database"
	"github.com/TracksApp/tracks/internal/models"
	"gorm.io/gorm"
)

// TagService handles tag business logic
type TagService struct{}

// NewTagService creates a new TagService
func NewTagService() *TagService {
	return &TagService{}
}

// GetOrCreateTag finds or creates a tag by name
func (s *TagService) GetOrCreateTag(tx *gorm.DB, userID uint, name string) (*models.Tag, error) {
	var tag models.Tag

	// Try to find existing tag
	if err := tx.Where("user_id = ? AND name = ?", userID, name).First(&tag).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			// Create new tag
			tag = models.Tag{
				UserID: userID,
				Name:   name,
			}
			if err := tx.Create(&tag).Error; err != nil {
				return nil, err
			}
		} else {
			return nil, err
		}
	}

	return &tag, nil
}

// SetTodoTags sets the tags for a todo, replacing all existing tags
func (s *TagService) SetTodoTags(tx *gorm.DB, userID, todoID uint, tagNames []string) error {
	// Remove existing taggings
	if err := tx.Where("taggable_id = ? AND taggable_type = ?", todoID, "Todo").
		Delete(&models.Tagging{}).Error; err != nil {
		return err
	}

	// Add new taggings
	for _, tagName := range tagNames {
		if tagName == "" {
			continue
		}

		tag, err := s.GetOrCreateTag(tx, userID, tagName)
		if err != nil {
			return err
		}

		tagging := models.Tagging{
			TagID:        tag.ID,
			TaggableID:   todoID,
			TaggableType: "Todo",
		}

		if err := tx.Create(&tagging).Error; err != nil {
			return err
		}
	}

	return nil
}

// SetRecurringTodoTags sets the tags for a recurring todo
func (s *TagService) SetRecurringTodoTags(tx *gorm.DB, userID, recurringTodoID uint, tagNames []string) error {
	// Remove existing taggings
	if err := tx.Where("taggable_id = ? AND taggable_type = ?", recurringTodoID, "RecurringTodo").
		Delete(&models.Tagging{}).Error; err != nil {
		return err
	}

	// Add new taggings
	for _, tagName := range tagNames {
		if tagName == "" {
			continue
		}

		tag, err := s.GetOrCreateTag(tx, userID, tagName)
		if err != nil {
			return err
		}

		tagging := models.Tagging{
			TagID:        tag.ID,
			TaggableID:   recurringTodoID,
			TaggableType: "RecurringTodo",
		}

		if err := tx.Create(&tagging).Error; err != nil {
			return err
		}
	}

	return nil
}

// GetUserTags returns all tags for a user
func (s *TagService) GetUserTags(userID uint) ([]models.Tag, error) {
	var tags []models.Tag

	if err := database.DB.Where("user_id = ?", userID).
		Order("name ASC").
		Find(&tags).Error; err != nil {
		return nil, err
	}

	return tags, nil
}

// GetTagCloud returns tags with usage counts
func (s *TagService) GetTagCloud(userID uint) ([]map[string]interface{}, error) {
	type TagCount struct {
		TagID uint
		Name  string
		Count int64
	}

	var tagCounts []TagCount

	err := database.DB.Table("tags").
		Select("tags.id as tag_id, tags.name, COUNT(taggings.id) as count").
		Joins("LEFT JOIN taggings ON taggings.tag_id = tags.id").
		Where("tags.user_id = ?", userID).
		Group("tags.id, tags.name").
		Order("count DESC").
		Scan(&tagCounts).Error

	if err != nil {
		return nil, err
	}

	result := make([]map[string]interface{}, len(tagCounts))
	for i, tc := range tagCounts {
		result[i] = map[string]interface{}{
			"tag_id": tc.TagID,
			"name":   tc.Name,
			"count":  tc.Count,
		}
	}

	return result, nil
}
