module Moirai
  class TranslationFilesController < ApplicationController
    before_action :load_file_handler, only: [:index, :show, :create_or_update]
    before_action :set_translation_file, only: [:show]

    def index
      @files = @file_handler.file_paths.map do |path|
        {
          id: Digest::SHA256.hexdigest(path),
          name: File.basename(path),
          path: path
        }
      end
    end

    def show
      @translation_keys = @file_handler.parse_file(@decoded_path)
      @locale = @file_handler.get_first_key(@decoded_path)
      @translations = Moirai::Translation.by_file_path(@decoded_path)
    end

    def create_or_update
      if (translation = Translation.find_by(key: translation_params[:key], locale: translation_params[:locale]))
        handle_update(translation)
      else
        handle_create
      end
    end

    def open_pr
      flash.notice = "I created an amazing PR"
      changes = Moirai::TranslationDumper.new.call
      Moirai::PullRequestCreator.new.create_pull_request(changes)
      redirect_back_or_to(root_path)
    end

    private

    def handle_update(translation)
      if translation_params[:value].blank? || translation_same_as_in_file?
        translation.destroy
        flash.notice = "Translation #{translation.key} was successfully deleted."
        redirect_to_translation_file(translation.find_file_path)
        return
      end

      if translation.update(value: translation_params[:value])
        flash.notice = "Translation #{translation.key} was successfully updated."
      else
        flash.alert = translation.errors.full_messages.join(", ")
      end

      success_response(translation)
    end

    def handle_create
      file_path = KeyFinder.new.file_path_for(translation_params[:key], locale: translation_params[:locale])

      if translation_same_as_in_file?
        flash.alert = "Translation #{translation_params[:key]} already exists."
        redirect_to_translation_file(file_path)
        return
      end

      translation = Translation.new(translation_params)
      translation.locale = @file_handler.get_first_key(file_path) if file_path.present?

      if translation.save
        flash.notice = "Translation #{translation.key} was successfully created."
        success_response(translation)
      else
        flash.alert = translation.errors.full_messages.join(", ")
        redirect_to moirai_translation_files_path, status: :unprocessable_entity
      end
    end

    def success_response(translation)
      respond_to do |format|
        format.json do
          render json: {}
        end
        format.all do
          redirect_to_translation_file(translation.find_file_path)
        end
      end
    end

    def redirect_to_translation_file(file_path)
      redirect_back_or_to moirai_translation_file_path(Digest::SHA256.hexdigest(file_path))
    end

    def set_translation_file
      @file_path = @file_handler.file_hashes[params[:id]]
      if @file_path.nil?
        flash.alert = "File not found"
        redirect_to moirai_translation_files_path, status: :not_found
        return
      end
      @decoded_path = CGI.unescape(@file_path)
    end

    def translation_params
      params.require(:translation).permit(:key, :locale, :value)
    end

    def load_file_handler
      @file_handler = Moirai::TranslationFileHandler.new
    end

    def translation_same_as_in_file?
      file_path = KeyFinder.new.file_path_for(translation_params[:key], locale: translation_params[:locale])

      return false if file_path.blank?
      return false unless File.exist?(file_path)

      translation_params[:value] == @file_handler.parse_file(file_path)[translation_params[:key]]
    end
  end
end
