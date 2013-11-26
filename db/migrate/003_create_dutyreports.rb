class CreateDutyreports < ActiveRecord::Migration
  def change
    create_table :dutyreports do |t|
      t.integer :day_id
      t.time :call_time
      t.string :client
      t.string :problem
      t.time :handle_time
      t.string :report
      
      t.timestamps
    end
  end
end
