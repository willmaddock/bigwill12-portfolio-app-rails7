require "test_helper"

class StudentTest < ActiveSupport::TestCase
  # Test 1: Ensure that a student cannot be saved without a first name
  test "should raise error when saving student without first name" do
    student = Student.new(
      first_name: nil,
      last_name: "Nikola",
      school_email: "nikola@msudenver.edu",
      major: "CS",
      graduation_date: Date.today
    )
    assert_raises ActiveRecord::RecordInvalid do
      student.save!
    end
  end

  # Test 2: Ensure that duplicate school emails are not allowed
  test "should not allow duplicate school email" do
    # Ensure the original student is saved with a unique email
    student = Student.create!(
      first_name: "Alice",
      last_name: "Johnson",
      school_email: "alice.johnson@msudenver.edu",
      major: "Computer Science",
      graduation_date: Date.new(2025, 5, 15)
    )

    duplicate_student = Student.new(
      first_name: "Bob",
      last_name: "Smith",
      school_email: "alice.johnson@msudenver.edu", # Using the same email as the existing student
      major: "Mathematics",
      graduation_date: Date.today
    )
    assert_not duplicate_student.valid?
    assert_includes duplicate_student.errors[:school_email], "has already been taken"
  end

  # Test 3: Ensure that a student can be saved with valid attributes
  test "should save student with valid attributes" do
    student = Student.create!(
      first_name: "Charlie",
      last_name: "Brown",
      school_email: "charlie.brown@msudenver.edu",
      major: "Engineering",
      graduation_date: Date.today
    )
    assert student.persisted?, "Student was not persisted"
  end

  # Test 4: Ensure that major cannot be empty
  test "major should be present" do
    student = Student.new(
      first_name: "Daisy",
      last_name: "Miller",
      school_email: "daisy.miller@msudenver.edu",
      major: "",
      graduation_date: Date.new(2025, 5, 15)
    )
    assert_not student.valid?
    assert_includes student.errors[:major], "can't be blank"
  end

  # Test 5: Ensure that the email format is valid
  test "email should have valid format" do
    student = Student.new(
      first_name: "Eve",
      last_name: "Taylor",
      school_email: "invalid_email_format",
      major: "Biology",
      graduation_date: Date.new(2025, 5, 15)
    )
    assert_not student.valid?
    assert_includes student.errors[:school_email], "must be a valid MSU Denver email"
  end

  # Test 6: Ensure that email addresses are unique
  test "email should be unique" do
    student = Student.create!(
      first_name: "Frank",
      last_name: "White",
      school_email: "frank.white@msudenver.edu",
      major: "Physics",
      graduation_date: Date.new(2025, 5, 15)
    )

    duplicate_student = Student.new(
      first_name: "Grace",
      last_name: "Green",
      school_email: "frank.white@msudenver.edu", # Using the same email as the existing student
      major: "Chemistry",
      graduation_date: Date.today
    )
    assert_not duplicate_student.valid?
    assert_includes duplicate_student.errors[:school_email], "has already been taken"
  end

  # Test 7: Ensure that graduation date cannot be empty
  test "graduation date should be present" do
    student = Student.new(
      first_name: "Hannah",
      last_name: "Clark",
      school_email: "hannah.clark@msudenver.edu",
      major: "Psychology",
      graduation_date: nil
    )
    assert_not student.valid?
    assert_includes student.errors[:graduation_date], "can't be blank"
  end

  # Test 8: Ensure that the profile picture attachment is optional
  test "profile picture is optional" do
    # Create a student without a profile picture
    student_without_picture = Student.new(
      first_name: "Isaac",
      last_name: "Newton",
      school_email: "isaac.newton@msudenver.edu",
      major: "Mathematics",
      graduation_date: Date.new(2025, 5, 15)
    )

    # Save the student
    assert student_without_picture.save, "Student without profile picture should be saved successfully"

    # Check that the profile picture is not attached
    assert_not student_without_picture.profile_picture.attached?, "Profile picture should not be attached for a student without a profile picture"
  end
end