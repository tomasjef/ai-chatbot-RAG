class Admin::AssistantsController < ApplicationController
  http_basic_authenticate_with name: "admin", password: "halo-demo"

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
        source_name: uploaded.original_filename
      )
      redirect_to admin_assistant_path(@assistant),
                  notice: "Ingested #{count} passages from #{uploaded.original_filename}."
    else
      redirect_to admin_assistant_path(@assistant), alert: "Please choose a PDF to upload."
    end
  end
end
