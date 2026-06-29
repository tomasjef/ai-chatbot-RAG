class AssistantsController < ApplicationController
  def index
    @assistants = Assistant.all
  end

  def show
    @assistant = Assistant.find(params[:id])
  end

  def ask
    @assistant    = Assistant.find(params[:id])
    @question     = params[:question]
    @entries      = RetrievalService.call(@assistant, @question)
    result        = AnswerService.call(@assistant, @question, @entries)
    @answer       = result[:answer]
    @used_entries = result[:used_entries]
    render :show
  end
end
