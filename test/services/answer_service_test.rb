require "test_helper"

class AnswerServiceTest < ActiveSupport::TestCase
  test "returns a bounded fallback when no uploaded document sources are available" do
    result = AnswerService.call(assistants(:one), "What is the daily transfer limit?", [])

    assert_equal [], result[:used_entries]
    assert_includes result[:answer], "uploaded documents"
  end
end
