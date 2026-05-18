class ChangeConditionDataTypeInHealthRecords < ActiveRecord::Migration[7.2]
  def up
    # ⭕ 決定的な修正: 第3引数は純粋な型シンボル（:integer）にし、USINGキャストは「using:」オプションで正確に渡します
    change_column :health_records, :condition, :integer, using: 'condition::integer', default: 3, null: false
  end

  def down
    change_column :health_records, :condition, :string, default: nil, null: true
  end
end
