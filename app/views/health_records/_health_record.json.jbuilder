json.extract! health_record, :id, :user_id, :recorded_on, :condition, :sleep_time, :breakfast_memo, :lunch_memo, :dinner_memo, :ai_advice, :created_at, :updated_at
json.url health_record_url(health_record, format: :json)
