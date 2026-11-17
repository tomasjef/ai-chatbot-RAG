require "test_helper"

class AssistantsControllerTest < ActionDispatch::IntegrationTest
  test "an OpenAI outage gets an apology instead of an error page" do
    with_singleton_method(RetrievalService, :call, ->(*) { raise Faraday::ConnectionFailed, "down" }) do
      post ask_path, params: { question: "What are the fees?" }
    end

    assert_response :success
    assert_select ".message__body", text: /can't answer right now/
  end

  test "admin gets a clear message for a file that is not a readable PDF" do
    file = Rack::Test::UploadedFile.new(StringIO.new("not a pdf"), "application/pdf", original_filename: "notes.pdf")

    post admin_ingest_path, params: { file: file },
                            headers: { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "halo-demo") }

    assert_redirected_to admin_root_path
    assert_match "Couldn't read notes.pdf", flash[:alert]
  end

  private

  def with_singleton_method(object, method_name, replacement)
    original = object.method(method_name)
    object.define_singleton_method(method_name, replacement)
    yield
  ensure
    object.define_singleton_method(method_name, original)
  end
end
