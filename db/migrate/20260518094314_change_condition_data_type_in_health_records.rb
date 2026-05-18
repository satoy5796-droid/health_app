class ChangeConditionDataTypeInHealthRecords < ActiveRecord::Migration[7.2]
  def up
    # 本番PostgreSQLで安全かつ確実に文字列型から整数型へキャスト（変換）する記述
    change_column :health_records, :condition, 'integer USING CAST(condition AS integer)', default: 3, null: false
  end

  def down
    change_column :health_records, :condition, :string, default: nil, null: true
  end
end
