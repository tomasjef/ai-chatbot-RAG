require "test_helper"
require "stringio"

class AnswerServiceTest < ActiveSupport::TestCase
  test "returns a bounded fallback when no uploaded document sources are available" do
    result = AnswerService.call(assistants(:one), "What is the daily transfer limit?", [])

    assert_equal [], result[:used_entries]
    assert_includes result[:answer], "uploaded documents"
  end

  test "uses only valid one based source numbers from the model response" do
    document = documents(:one)
    document.pdf.attach(io: StringIO.new("%PDF-1.4\n"), filename: "terms.pdf", content_type: "application/pdf")

    entry = knowledge_entries(:one)
    entry.update!(
      document: document,
      title: "Transfer limit source",
      content: "The transfer limit is GBP 25,000."
    )

    response = {
      "choices" => [
        {
          "message" => {
            "content" => {
              answer: "The transfer limit is GBP 25,000.",
              sources: [ 0, 1, 99 ]
            }.to_json
          }
        }
      ]
    }
    fake_client = Object.new
    fake_client.define_singleton_method(:chat) { |parameters:| response }

    OpenAI::Client.stub(:new, fake_client) do
      result = AnswerService.call(assistants(:one), "What is the transfer limit?", [ entry ])

      assert_equal "The transfer limit is GBP 25,000.", result[:answer]
      assert_equal [ entry ], result[:used_entries]
    end
  end
end
