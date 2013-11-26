class CreatePeriods < ActiveRecord::Migration
  def change
    create_table :periods do |t|
      t.date :start
      t.date :stop
      t.string :project_id
    end
  end
end
