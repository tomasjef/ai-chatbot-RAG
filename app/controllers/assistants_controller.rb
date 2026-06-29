class AssistantsController < ApplicationController
  before_action :authenticate_demo_access

  rate_limit to: ENV.fetch("ASK_RATE_LIMIT_MAX", 20).to_i,
    within: ENV.fetch("ASK_RATE_LIMIT_WINDOW_SECONDS", 1.hour.to_i).to_i.seconds,
    only: :ask,
    with: -> { render plain: "Too many questions. Please try again later.", status: :too_many_requests }

  def index
    @assistants = Assistant.all
  end

  def show
    @assistant = Assistant.find(params[:id])
  end

  def ask
    @assistant    = Assistant.find(params[:id])
    @question     = params[:question]
    @conversation_history = conversation_history
    @entries      = RetrievalService.call(@assistant, retrieval_question)
    result        = AnswerService.call(@assistant, @question, @entries, @conversation_history)
    @answer       = result[:answer]
    @used_entries = result[:used_entries]
    render :show
  end

  private

  def conversation_history
    JSON.parse(params[:conversation_history].presence || "[]")
      .filter_map { |message| normalized_message(message) }
      .last(8)
  rescue JSON::ParserError
    []
  end

  def normalized_message(message)
    role = message["role"].to_s
    content = message["content"].to_s.squish
    return unless %w[user assistant].include?(role) && content.present?

    { "role" => role, "content" => content.truncate(1_000) }
  end

  def retrieval_question
    previous_user_questions = @conversation_history
      .select { |message| message["role"] == "user" }
      .last(3)
      .map { |message| message["content"] }

    ([ *previous_user_questions, @question.to_s ].compact_blank).join("\n")
  end
end
