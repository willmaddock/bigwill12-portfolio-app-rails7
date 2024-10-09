class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]

  # GET /students or /students.json
  def index
    # Log the request parameters for debugging purposes
    Rails.logger.info "Params: #{params.inspect}"

    # Initialize @students as an empty array (no students displayed initially)
    @students = []

    # Params[:search]: Data is passed from the form field as a hash to know
    # what attribute and value to search and will be stored in @search_params
    @search_params = params[:search] || {} # If no search criteria is provided, assign an empty hash {}

    # Check if the "Show All" button was clicked
    if params[:show_all]
      # All students will be displayed
      @students = Student.all
    elsif @search_params.present? && !@search_params.values.all?(&:blank?)
      # Only execute the following if there are search parameters provided
      @students = Student.all

      # Filter by major if provided
      if @search_params[:major].present?
        @students = @students.where(major: @search_params[:major])
      end

      # Graduation date filtering
      if @search_params[:graduation_date].present? && @search_params[:date_filter].present?
        date = Date.parse(@search_params[:graduation_date])
        if @search_params[:date_filter] == "before"
          @students = @students.where("graduation_date < ?", date)
        elsif @search_params[:date_filter] == "after"
          @students = @students.where("graduation_date > ?", date)
        end
      end

      # Log the search parameters to see what the user is searching for
      Rails.logger.info "Search Params: #{@search_params.inspect}"
    end

    # Handle pagination after filtering
    per_page = params[:per_page] || 10 # Default to 10 if not specified
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
        format.html { redirect_to student_url(@student), notice: "Student was successfully created." }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1 or /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to student_url(@student), notice: "Student was successfully updated." }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1 or /students/1.json
  def destroy
    @student.destroy!

    respond_to do |format|
      format.html { redirect_to students_url, notice: "Student was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_student
    @student = Student.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def student_params
    params.require(:student).permit(:first_name, :last_name, :school_email, :major, :graduation_date, :profile_picture)
  end
end