class Student < ApplicationRecord
  has_one_attached :profile_picture # For ActiveStorage

  validates :first_name, :last_name, :major, presence: true, length: { in: 2..25 }
  validates :school_email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@msudenver.edu\z/i, message: "must be a valid MSU Denver email" }
  validates :graduation_date, presence: true
end