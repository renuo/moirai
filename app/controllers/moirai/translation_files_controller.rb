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
      @translations = Moirai::Translation.find_by_file_path(@decoded_path)
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
      translation_from_file = @file_handler.parse_file(translation.find_file_path)
      if translation_from_file[translation.key] == translation_params[:value] || translation_params[:value].blank?
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
      translation_from_file = @file_handler.parse_file(file_path)
      if translation_from_file[translation_params[:key]] == translation_params[:value]
        flash.alert = "Translation #{translation_params[:key]} already exists."
        redirect_to_translation_file(file_path)
        return
      end

      translation = Translation.new(translation_params)
      translation.locale = @file_handler.get_first_key(file_path)
      if translation.save
        flash.notice = "Translation #{translation.key} was successfully created."
      else
        flash.alert = translation.errors.full_messages.join(", ")
      end

      success_response(translation)
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
      @decoded_path = CGI.unescape(@file_path)
    end

    def translation_params
      params.require(:translation).permit(:key, :locale, :value, :file_path)
    end

    def load_file_handler
      @file_handler = Moirai::TranslationFileHandler.new
    end
  end
end
