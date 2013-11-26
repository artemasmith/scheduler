class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :day
      t.integer :dpeople_id
      t.integer :month
      t.integer :year
      t.string :project_id
    end
    add_index :schedules, [:day,:dpeople_id,:month,:year,:project_id], unique: true, name: 'schedule_uniq'
  end
end
