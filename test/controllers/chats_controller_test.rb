require "test_helper"
require "stringio"

class AssistantsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get assistants_url
    assert_response :success
  end

  test "demo password protects public assistant pages when configured" do
    with_demo_credentials(password: "secret") do
      get assistants_url
      assert_response :unauthorized
    end
  end

  test "demo password allows public assistant pages with valid credentials" do
    with_demo_credentials(username: "portfolio", password: "secret") do
      get assistants_url, headers: {
        "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("portfolio", "secret")
      }

      assert_response :success
    end
  end

  test "admin pages require admin credentials" do
    get admin_assistants_url
    assert_response :unauthorized
  end

  test "admin pages allow valid admin credentials" do
    with_admin_credentials(username: "owner", password: "secret") do
      get admin_assistants_url, headers: {
        "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("owner", "secret")
      }

      assert_response :success
    end
  end

  test "assistant page renders profile suggested questions" do
    get assistant_url(assistants(:one))

    assert_response :success
    assert_includes response.body, "What can I ask about?"
    assert_includes response.body, "Prototype AI chatbot"
  end

  test "ask accepts recent browser session conversation history" do
    captured_history = nil
    captured_retrieval_question = nil
    history = [
      { role: "user", content: "Tell me about account plans" },
      { role: "assistant", content: "There are free and paid plans." }
    ]

    with_singleton_method(RetrievalService, :call, ->(_assistant, question) {
      captured_retrieval_question = question
      []
    }) do
      with_singleton_method(AnswerService, :call, ->(_assistant, _question, _entries, conversation_history) {
        captured_history = conversation_history
        { answer: "Halo Plus costs 4 pounds a month.", used_entries: [] }
      }) do
        post ask_assistant_url(assistants(:one)), params: {
          question: "What about Plus?",
          conversation_history: history.to_json
        }
      end
    end

    assert_response :success
    assert_equal "Tell me about account plans", captured_history.first["content"]
    assert_includes captured_retrieval_question, "Tell me about account plans"
    assert_includes captured_retrieval_question, "What about Plus?"
  end

  test "ask renders source buttons that link to attached PDFs" do
    document = documents(:one)
    document.pdf.attach(io: StringIO.new("%PDF-1.4\n"), filename: "terms.pdf", content_type: "application/pdf")
    entry = knowledge_entries(:one)
    entry.update!(document: document)

    with_singleton_method(RetrievalService, :call, ->(_assistant, _question) { [ entry ] }) do
      with_singleton_method(AnswerService, :call, ->(_assistant, _question, _entries, _conversation_history) {
        { answer: "Use the card settings screen.", used_entries: [ entry ] }
      }) do
        post ask_assistant_url(assistants(:one)), params: { question: "Where do I freeze my card?" }
      end
    end

    assert_response :success
    assert_includes response.body, "Sources"
    assert_includes response.body, document_path(document)
    assert_includes response.body, "source-button__icon"
  end

  test "document PDFs require demo password when demo protection is configured" do
    document = documents(:one)
    document.pdf.attach(io: StringIO.new("%PDF-1.4\n"), filename: "terms.pdf", content_type: "application/pdf")

    with_demo_credentials(password: "secret") do
      get document_url(document)
      assert_response :unauthorized
    end
  end

  test "document PDFs open inline with valid demo credentials" do
    document = documents(:one)
    document.pdf.attach(io: StringIO.new("%PDF-1.4\n"), filename: "terms.pdf", content_type: "application/pdf")

    with_demo_credentials(username: "portfolio", password: "secret") do
      get document_url(document), headers: {
        "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("portfolio", "secret")
      }
    end

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_includes response.headers["Content-Disposition"], "inline"
  end

  private

  def with_demo_credentials(username: nil, password:)
    previous_username = ENV["DEMO_USERNAME"]
    previous_password = ENV["DEMO_PASSWORD"]
    ENV["DEMO_USERNAME"] = username if username
    ENV["DEMO_PASSWORD"] = password
    yield
  ensure
    ENV["DEMO_USERNAME"] = previous_username
    ENV["DEMO_PASSWORD"] = previous_password
  end

  def with_admin_credentials(username:, password:)
    previous_username = ENV["ADMIN_USERNAME"]
    previous_password = ENV["ADMIN_PASSWORD"]
    ENV["ADMIN_USERNAME"] = username
    ENV["ADMIN_PASSWORD"] = password
    yield
  ensure
    ENV["ADMIN_USERNAME"] = previous_username
    ENV["ADMIN_PASSWORD"] = previous_password
  end

  def with_singleton_method(object, method_name, replacement)
    original = object.method(method_name)
    object.define_singleton_method(method_name, replacement)
    yield
  ensure
    object.define_singleton_method(method_name, original)
  end
end
