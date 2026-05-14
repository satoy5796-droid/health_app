class ChangeConditionToIntegerInHealthRecords < ActiveRecord::Migration[7.2]
  def change
    # PostgreSQLやMySQLの型変更によるエラーを防ぐため、一度削除して再作成（または明示的キャスト）
    change_column :health_records, :condition, :integer, using: 'condition::integer', default: 3, null: false
  end
end
