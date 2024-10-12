require 'faker' # Ensure the Faker gem is loaded
require 'open-uri' # For opening profile picture URLs

# Purge existing profile photos and remove associated blobs and attachments
Student.find_each do |student|
  student.profile_picture.purge if student.profile_picture.attached?
end

# Ensure no orphaned blobs or attachments
ActiveStorage::Blob.where.missing(:attachments).find_each(&:purge)

# Clear all existing students
Student.destroy_all

# Generate 50 new student records
50.times do |i|
  student = Student.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    school_email: "student#{i+1}@msudenver.edu", # Ensures valid MSU Denver email
    major: Student::VALID_MAJORS.sample, # Assuming VALID_MAJORS exists
    graduation_date: Faker::Date.between(from: 2.years.ago, to: 2.years.from_now)
  )

  # Attach a profile picture using the RoboHash API
  profile_picture_url = "https://robohash.org/#{student.first_name}_#{student.last_name}"
  profile_picture = URI.open(profile_picture_url)
  student.profile_picture.attach(io: profile_picture, filename: "#{student.first_name}.jpg")
end

puts "50 students created with profile pictures."