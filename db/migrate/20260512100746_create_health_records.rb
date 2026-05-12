class CreateHealthRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :health_records do |t|
      t.references :user, null: false, foreign_key: true
      t.date :recorded_on
      t.integer :condition
      t.float :sleep_time
      t.text :breakfast_memo
      t.text :lunch_memo
      t.text :dinner_memo
      t.text :ai_advice

      t.timestamps
    end
    add_index :health_records, :recorded_on
  end
end
