class Attachment < ActiveRecord::Base
  belongs_to :todo, touch: true

  has_attached_file :file,
    url:  '/:class/:id/:basename.:extension',
    path: ":rails_root/db/assets/#{Rails.env}/:class/:id/:basename.:extension"

  do_not_validate_attachment_file_type :file
  # validates_attachment_content_type :file, :content_type => ["text/plain"]
end
