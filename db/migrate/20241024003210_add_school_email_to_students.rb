class AddSchoolEmailToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :school_email, :string
  end
end
