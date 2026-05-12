require "application_system_test_case"

class HealthRecordsTest < ApplicationSystemTestCase
  setup do
    @health_record = health_records(:one)
  end

  test "visiting the index" do
    visit health_records_url
    assert_selector "h1", text: "Health records"
  end

  test "should create health record" do
    visit health_records_url
    click_on "New health record"

    fill_in "Ai advice", with: @health_record.ai_advice
    fill_in "Breakfast memo", with: @health_record.breakfast_memo
    fill_in "Condition", with: @health_record.condition
    fill_in "Dinner memo", with: @health_record.dinner_memo
    fill_in "Lunch memo", with: @health_record.lunch_memo
    fill_in "Recorded on", with: @health_record.recorded_on
    fill_in "Sleep time", with: @health_record.sleep_time
    fill_in "User", with: @health_record.user_id
    click_on "Create Health record"

    assert_text "Health record was successfully created"
    click_on "Back"
  end

  test "should update Health record" do
    visit health_record_url(@health_record)
    click_on "Edit this health record", match: :first

    fill_in "Ai advice", with: @health_record.ai_advice
    fill_in "Breakfast memo", with: @health_record.breakfast_memo
    fill_in "Condition", with: @health_record.condition
    fill_in "Dinner memo", with: @health_record.dinner_memo
    fill_in "Lunch memo", with: @health_record.lunch_memo
    fill_in "Recorded on", with: @health_record.recorded_on
    fill_in "Sleep time", with: @health_record.sleep_time
    fill_in "User", with: @health_record.user_id
    click_on "Update Health record"

    assert_text "Health record was successfully updated"
    click_on "Back"
  end

  test "should destroy Health record" do
    visit health_record_url(@health_record)
    accept_confirm { click_on "Destroy this health record", match: :first }

    assert_text "Health record was successfully destroyed"
  end
end
