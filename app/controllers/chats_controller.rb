class ChatsController < ApplicationController
  def index
  end

  def ask
    @question     = params[:question]
    @entries      = RetrievalService.call(@question)
    result        = AnswerService.call(@question, @entries)
    @answer       = result[:answer]
    @used_entries = result[:used_entries]
  render :index
  end
end
