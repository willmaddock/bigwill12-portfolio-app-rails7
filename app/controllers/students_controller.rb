class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]

  # GET /students or /students.json
  def index
    Rails.logger.info "Params: #{params.inspect}"

    @search_params = params[:search] || {}
    @students = if params[:show_all]
                  Student.all
                elsif @search_params.present? && !@search_params.values.all?(&:blank?)
                  search_students(@search_params)
                else
                  Student.none # If no search criteria, set to an empty result
                end

    per_page = params[:per_page] || 10
    @students = @students.paginate(page: params[:page], per_page: per_page) if @students.present?
  end

  # GET /students/1 or /students/1.json
  def show
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit
  end

  # POST /students or /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        flash[:notice] = "Student was successfully created."
        format.html { redirect_to student_url(@student) }
        format.json { render :show, status: :created, location: @student }
      else
        flash.now[:alert] = "There was an error creating the student."
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1 or /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        flash[:notice] = "Student was successfully updated."
        format.html { redirect_to student_url(@student) }
        format.json { render :show, status: :ok, location: @student }
      else
        flash.now[:alert] = "There was an error updating the student."
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1 or /students/1.json
  def destroy
    @student.destroy!
    flash[:notice] = "Student was successfully destroyed."

    respond_to do |format|
      format.html { redirect_to students_url }
      format.json { head :no_content }
    end
  end

  private

  # Set the student for actions that require it
  def set_student
    @student = Student.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Student not found."
    redirect_to students_path
  end

  # Strong parameters for creating/updating students
  def student_params
    params.require(:student).permit(:first_name, :last_name, :school_email, :major, :graduation_date, :profile_picture)
  end

  # Method to handle searching students based on the search params
  def search_students(search_params)
    Rails.logger.info "Searching with params: #{search_params.inspect}" # Log search parameters
    students = Student.all

    if search_params[:major].present?
      students = students.where(major: search_params[:major])
    end

    if search_params[:graduation_date].present? && search_params[:date_filter].present?
      date = Date.parse(search_params[:graduation_date]) rescue nil
      if date.present?
        if search_params[:date_filter] == "before"
          students = students.where("graduation_date < ?", date)
        elsif search_params[:date_filter] == "after"
          students = students.where("graduation_date > ?", date)
        end
      end
    end

    Rails.logger.info "Found #{students.count} students" # Log the number of students found
    students
  end
end