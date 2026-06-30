class Admin::AssistantsController < ApplicationController
  before_action :authenticate_admin_access
  before_action :set_assistant

  def show
  end

  def ingest
    if params[:file].present?
      uploaded = params[:file]
      count = IngestionService.call(
        @assistant,
        uploaded.path,
        source_name: uploaded.original_filename,
        attachable: uploaded
      )
      redirect_to admin_root_path,
                  notice: "Ingested #{count} passages from #{uploaded.original_filename}."
    else
      redirect_to admin_root_path, alert: "Please choose a PDF to upload."
    end
  end

  private

  def set_assistant
    @assistant = Assistant.active
  end
end
