class Student < ApplicationRecord
  # ActiveStorage for attaching a profile picture
  has_one_attached :profile_picture, dependent: :purge_later

  # Validation for profile picture file type and size
  validate :acceptable_profile_picture

  # Predefined valid majors
  VALID_MAJORS = ["Computer Engineering BS", "Computer Information Systems BS",
                  "Computer Science BS", "Cybersecurity Major", "Data Science and Machine Learning Major"]

  # Validation for name, major, email, and graduation date
  validates :first_name, :last_name, :major, presence: true
  validates :school_email, presence: true, uniqueness: true,
            format: { with: /\A[\w+\-.]+@msudenver.edu\z/i, message: "must be a valid MSU Denver email" }
  validates :graduation_date, presence: true

  # Ensuring that the major selected is one of the predefined valid majors
  validates :major, inclusion: { in: VALID_MAJORS, message: "%{value} is not a valid major" }

  private

  # Custom validation for profile picture
  def acceptable_profile_picture
    # Ensure a profile picture is attached before checking other validations
    return unless profile_picture.attached?

    # Validate file type (only accept JPEG, PNG, or GIF)
    unless profile_picture.content_type.in?(%w[image/jpeg image/png image/gif])
      errors.add(:profile_picture, "must be a JPEG, PNG, or GIF")
    end

    # Validate file size (limit to 5MB)
    if profile_picture.blob.byte_size > 5.megabytes
      errors.add(:profile_picture, "must be smaller than 5MB")
    end
  end
end