class Attachment < ActiveRecord::Base
  belongs_to :todo, touch: true

  has_attached_file :file,
    url:  '/:class/:id/:basename.:extension',
    path: ":rails_root/db/assets/#{Rails.env}/:class/:id/:basename.:extension",
    override_file_permissions: 0660

  do_not_validate_attachment_file_type :file
  # validates_attachment_content_type :file, :content_type => ["text/plain"]

  before_destroy :delete_attached_file

  private

  def delete_attached_file
    file = nil
    save!
  end
end
