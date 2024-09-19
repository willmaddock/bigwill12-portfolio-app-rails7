class CreateStudents < ActiveRecord::Migration[7.1]
  def change
    create_table :students do |t|
      t.string :first_name
      t.string :last_name
      t.string :school_email
      t.string :major
      t.date :graduation_date

      t.timestamps
    end
  end
end
