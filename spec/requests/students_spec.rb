require 'rails_helper'

# Request specs for the Students resource focusing on HTTP requests
RSpec.describe "Students", type: :request do
  # GET /students (index)
describe "GET /students" do
  context "when students exist" do
    # Create multiple students for testing
    let!(:students) do
      [
        Student.create!(first_name: "Aaron", last_name: "Gordon", school_email: "gordon@msudenver.edu", major: "Computer Science BS", graduation_date: "2025-05-15"),
        Student.create!(first_name: "Jackie", last_name: "Joyner", school_email: "joyner@msudenver.edu", major: "Data Science and Machine Learning Major", graduation_date: "2026-05-15"),
        Student.create!(first_name: "Michael", last_name: "Jordan", school_email: "jordan@msudenver.edu", major: "Computer Engineering BS", graduation_date: "2024-05-15")
      ]
    end

    # Test 1: Returns a successful response and displays the search form
    it "returns a successful response and displays the search form" do
      get students_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Search') # Ensure search form is rendered
    end

    # Test 2: Ensure it does NOT display students without a search
    it "does not display students until a search is performed" do
      get students_path
      expect(response.body).to_not include("Aaron")
    end

    # Test 3: Handle missing records or no search criteria provided
    it "displays a message prompting to search" do
      get students_path
      expect(response.body).to include("Please enter search criteria to find students")
    end
  end

  context "when there are no students" do
    # Test 4: Check that no students are displayed when none exist
    it "displays a message when no students are found" do
      Student.delete_all # Ensure no students are present
      get students_path
      expect(response.body).to include("Please enter search criteria to find students")
    end
  end
end

# Search functionality
describe "GET /students (search functionality)" do
  let!(:student1) { Student.create!(first_name: "Aaron", last_name: "Gordon", school_email: "gordon@msudenver.edu", major: "Computer Science BS", graduation_date: "2025-05-15") }
  let!(:student2) { Student.create!(first_name: "Jackie", last_name: "Joyner", school_email: "joyner@msudenver.edu", major: "Data Science and Machine Learning Major", graduation_date: "2026-05-15") }

  # Test 5: Search by major
  it "returns students matching the major" do
    get students_path, params: { search: { major: "Computer Science BS" } }
    expect(response.body).to include("Aaron")
    expect(response.body).to_not include("Jackie")
  end

  # Test 6: Search by expected graduation date (before)
  it "returns students graduating before the given date" do
    get students_path, params: { search: { expected_graduation_date: "2026-01-01", date_type: "before" } }
    expect(response.body).to include("Aaron")
    expect(response.body).to_not include("Jackie")
  end

  # Test 7: Search by expected graduation date (after)
  it "returns students graduating after the given date" do
    get students_path, params: { search: { expected_graduation_date: "2025-01-01", date_type: "after" } }
    expect(response.body).to include("Jackie")
    expect(response.body).to_not include("Aaron")
  end
end

# POST /students (create)
describe "POST /students" do
  context "with valid parameters" do
    # Test 8: Create a new student and ensure it redirects
    it "creates a new student and redirects" do
      expect {
        post students_path, params: { student: { first_name: "Aaron", last_name: "Gordon", school_email: "gordon@msudenver.edu", major: "Computer Science BS", graduation_date: "2025-05-15" } }
      }.to change(Student, :count).by(1)

      expect(response).to have_http_status(:found)  # Expect redirect after creation
      follow_redirect!
      expect(response.body).to include("Aaron")  # Student's details in the response
    end

    # Test 9: Ensure that it returns a 201 status after successful creation
    it "returns a 201 status" do
      post students_path, params: { student: { first_name: "Aaron", last_name: "Gordon", school_email: "gordon@msudenver.edu", major: "Computer Science BS", graduation_date: "2025-05-15" } }
      expect(response).to have_http_status(:found)  # Redirect after creation
    end
  end

  context "with invalid parameters" do
    # Test 10: Ensure it does not create a student and returns a 422 status
    it "does not create a student and returns a 422 status" do
      invalid_attributes = { student: { first_name: "", last_name: "", school_email: "invalid", major: "", graduation_date: "" } }
      expect {
        post students_path, params: invalid_attributes
      }.not_to change(Student, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

# GET /students/:id (show)
describe "GET /students/:id" do
  context "when the student exists" do
    let!(:student) { Student.create!(first_name: "Aaron", last_name: "Gordon", school_email: "gordon@msudenver.edu", major: "Computer Science BS", graduation_date: "2025-05-15") }

    # Test 11: Ensure it returns a successful response (200 OK)
    it "returns a 200 OK status" do
      get student_path(student)
      expect(response).to have_http_status(:ok)
    end

    # Test 12: Ensure it includes the student's details in the response body
    it "includes the student's details in the response body" do
      get student_path(student)
      expect(response.body).to include("Aaron")
      expect(response.body).to include("gordon@msudenver.edu")
    end
  end

  # Test 13: Handle missing records
  it "redirects to the students index with a 302 status for a non-existent student" do
    get student_path(id: 9999)
    expect(response).to have_http_status(:found)  # Expect redirect to index
    follow_redirect!
    expect(response.body).to include("Student not found.")
  end
end

# DELETE /students/:id (destroy)
describe "DELETE /students/:id" do
  let!(:student) { Student.create!(first_name: "Aaron", last_name: "Gordon", school_email: "gordon@msudenver.edu", major: "Computer Science BS", graduation_date: "2025-05-15") }

  # Test 14: Deletes the student and redirects
  it "deletes the student and redirects" do
    expect {
      delete student_path(student)
    }.to change(Student, :count).by(-1)

    expect(response).to have_http_status(:found)  # Expect redirect after deletion
    follow_redirect!
    expect(response.body).to include("Student was successfully destroyed.")
  end

  # Test 15: Returns a 302 and redirects for non-existent student deletion
  it "returns a 302 status and redirects for a non-existent student deletion" do
    delete "/students/9999"
    expect(response).to have_http_status(:found)  # Redirect to index
    follow_redirect!
    expect(response.body).to include("Student not found.")
  end

  # Test 16: Ensure pagination is applied correctly
  it "paginates results and returns the correct number of students per page" do
    create_list(:student, 25) # Creates 25 students using FactoryBot or a similar method
    get students_path, params: { per_page: 10, page: 1 }

    expect(response.body.scan(/<tr>/).count).to eq(11) # 10 students + 1 header row
  end
end
end

