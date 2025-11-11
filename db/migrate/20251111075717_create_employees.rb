class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :job_title, null: false
      t.string :country, null: false
      t.decimal :salary, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
