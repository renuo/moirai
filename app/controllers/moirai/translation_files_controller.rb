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
      @translation_keys = @file_handler.parse_file(@file_path)
      @locale = @file_handler.get_first_key(@file_path)
      @translations = Moirai::Translation.by_file_path(@file_path)
    end

    def create_or_update
      if (translation = Translation.find_by(key: translation_params[:key], locale: translation_params[:locale]))
        handle_update(translation)
      else
        handle_create
      end
    end

    def open_pr
      flash.notice = "I created an amazing Pull Request"
      changes = Moirai::TranslationDumper.new.call
      Moirai::PullRequestCreator.new.create_pull_request(changes)
      redirect_back_or_to(root_path)
    end

    private

    def handle_update(translation)
      if translation_params[:value].blank? || translation_same_as_current?
        translation.destroy
        flash.notice = "Translation #{translation.key} was successfully deleted."
        redirect_to_translation_file(translation.file_path)
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
      if translation_same_as_current?
        flash.alert = "Translation #{translation_params[:key]} already exists."
        redirect_back_or_to moirai_translation_files_path, status: :unprocessable_entity
        return
      end

      translation = Translation.new(translation_params)

      if translation.save
        flash.notice = "Translation #{translation.key} was successfully created."
        success_response(translation)
      else
        flash.alert = translation.errors.full_messages.join(", ")
        redirect_back_or_to moirai_translation_files_path, status: :unprocessable_entity
      end
    end

    def success_response(translation)
      respond_to do |format|
        format.json do
          flash.discard
          render json: {}
        end
        format.all do
          redirect_to_translation_file(translation.file_path)
        end
      end
    end

    def redirect_to_translation_file(file_path)
      redirect_back_or_to moirai_translation_file_path(Digest::SHA256.hexdigest(file_path))
    end

    def set_translation_file
      @file_path = @file_handler.file_hashes[params[:hashed_file_path]]
      if @file_path.nil?
        flash.alert = "File not found"
        redirect_to moirai_translation_files_path, status: :not_found
      end
    end

    def translation_params
      params.require(:translation).permit(:key, :locale, :value)
    end

    def load_file_handler
      @file_handler = Moirai::TranslationFileHandler.new
    end

    # TODO: to resolve the last point of the TODOs we could look at the current translation (without moirai)
    # I quickly tried but I need to use the original backend instead of the moirai one
    # The problem is that if we set a value that is the same as currently being used via fallback,
    # it will create an entry in the database, and afterwards will try to add it in the PR, which we don't want.
    def translation_same_as_current?
      file_paths = KeyFinder.new.file_paths_for(translation_params[:key], locale: translation_params[:locale])

      return false if file_paths.empty?
      return false unless file_paths.all? { |file_path| File.exist?(file_path) }

      translation_params[:value] == @file_handler.parse_file(file_paths.first)[translation_params[:key]]
    end
  end
end
