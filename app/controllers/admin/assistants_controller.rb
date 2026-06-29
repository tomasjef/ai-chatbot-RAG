class Admin::AssistantsController < ApplicationController
  before_action :authenticate_admin_access

  def index
    @assistants = Assistant.all
  end

  def show
    @assistant = Assistant.find(params[:id])
  end

  def ingest
    @assistant = Assistant.find(params[:id])

    if params[:file].present?
      uploaded = params[:file]
      count = IngestionService.call(
        @assistant,
        uploaded.path,
        source_name: uploaded.original_filename,
        attachable: uploaded
      )
      redirect_to admin_assistant_path(@assistant),
                  notice: "Ingested #{count} passages from #{uploaded.original_filename}."
    else
      redirect_to admin_assistant_path(@assistant), alert: "Please choose a PDF to upload."
    end
  end
end
