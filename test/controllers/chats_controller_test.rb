require "test_helper"
require "stringio"

class AssistantsControllerTest < ActionDispatch::IntegrationTest
  test "should get assistant" do
    get root_url
    assert_response :success
  end

  test "demo password protects public assistant pages when configured" do
    with_demo_credentials(password: "secret") do
      get root_url
      assert_response :unauthorized
    end
  end

  test "demo password allows public assistant pages with valid credentials" do
    with_demo_credentials(username: "portfolio", password: "secret") do
      get root_url, headers: {
        "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("portfolio", "secret")
      }

      assert_response :success
    end
  end

  test "admin pages require admin credentials" do
    get admin_root_url
    assert_response :unauthorized
  end

  test "admin pages allow valid admin credentials" do
    with_admin_credentials(username: "owner", password: "secret") do
      get admin_root_url, headers: {
        "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("owner", "secret")
      }

      assert_response :success
    end
  end

  test "assistant page renders halo suggested questions" do
    get root_url

    assert_response :success
    assert_includes response.body, "Check my balance"
    assert_includes response.body, "Prototype AI chatbot"
  end

  test "halo assistant page keeps chat actions inside controller scope" do
    get root_url

    assert_response :success

    document = Nokogiri::HTML(response.body)
    chat_controller = document.at_css("[data-controller~='chat']")

    assert_not_nil chat_controller
    assert_includes chat_controller["class"], "halo-page"
    assert_not_nil chat_controller.at_css("[data-action='chat#clear']")
    assert_equal 2, chat_controller.css("form[action='#{ask_path}']").size
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
        post ask_url, params: {
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

  test "ask renders source buttons through the app document route" do
    document = documents(:one)
    document.pdf.attach(io: StringIO.new("%PDF-1.4\n"), filename: "uploaded_terms.pdf", content_type: "application/pdf")
    entry = knowledge_entries(:one)
    entry.update!(document: document)

    with_singleton_method(RetrievalService, :call, ->(_assistant, _question) { [ entry ] }) do
      with_singleton_method(AnswerService, :call, ->(_assistant, _question, _entries, _conversation_history) {
        { answer: "Use the card settings screen.", used_entries: [ entry ] }
      }) do
        post ask_url, params: { question: "Where do I freeze my card?" }
      end
    end

    assert_response :success
    assert_includes response.body, "Sources"
    assert_includes response.body, document_path(document)
    refute_includes response.body, rails_blob_path(document.pdf, disposition: "inline")
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
    uploaded_pdf = "%PDF-1.4\nuploaded source pdf\n%%EOF\n"
    document.pdf.attach(io: StringIO.new(uploaded_pdf), filename: "terms.pdf", content_type: "application/pdf")

    with_demo_credentials(username: "portfolio", password: "secret") do
      get document_url(document), headers: {
        "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("portfolio", "secret")
      }
    end

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_includes response.headers["Content-Disposition"], "inline"
    assert_equal uploaded_pdf, response.body
  end

  test "seeded document PDFs fall back to bundled source files" do
    document = documents(:one)
    document.update!(filename: "halo_payments_limits_and_fees.pdf")

    get document_url(document)

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_includes response.headers["Content-Disposition"], "inline"
    assert_includes response.body, "%PDF"
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
