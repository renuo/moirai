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

      respond_to do |format|
        format.html { render :index }
        format.json { render json: @files }
      end
    end

    def show
      @translation_keys = @file_handler.parse_file(@file_path)
      @locale = @file_handler.get_first_key(@file_path)
      @translations = Moirai::Translation.by_file_path(@file_path)

      respond_to do |format|
        format.html { render :show }
        format.json { render json: {translation_keys: @translation_keys, locale: @locale, translations: @translations} }
      end
    end

    def create_or_update
      if (translation = Translation.find_by(key: translation_params[:key], locale: translation_params[:locale]))
        handle_update(translation)
      else
        handle_create
      end
    end

    def open_pr
      changes = Moirai::TranslatDumper.new.call
      Moirai::PullRequestCreator.new.create_pull_request(changes)

      respond_to do |format|
        format.html { redirect_back_or_to(root_path, notice: "I created an amazing Pull Request") }
        format.json { render json: {message: "Pull Request created"}, status: :ok }
      end
    end

    private

    def handle_update(translation)
      if translation_params[:value].blank? || translation_same_as_current?
        fallback_translation = {key: translation.key, value: translation.value}
        translation.destroy
        respond_to do |format|
          format.html { redirect_to_translation_file(translation.file_path, notice: "Translation #{translation.key} was successfully deleted.") }
          format.json { render json: {message: "Translation deleted", fallback_translation: fallback_translation}, status: :ok }
        end
        return
      end

      if translation.update(value: translation_params[:value])
        respond_to do |format|
          format.html { redirect_to_translation_file(translation.file_path, notice: "Translation #{translation.key} was successfully updated.") }
          format.json { render json: {message: "Translation updated", translation: translation}, status: :ok }
        end
      else
        respond_to do |format|
          format.html {
            flash.now[:alert] = translation.errors.full_messages.join(", ")
            redirect_back(fallback_location: root_path)
          }
          format.json { render json: {errors: translation.errors.full_messages}, status: :unprocessable_entity }
        end
      end
    end

    def handle_create
      if translation_same_as_current?
        respond_to do |format|
          format.html {
            flash.now[:alert] = "Translation #{translation_params[:key]} already exists."
            redirect_back(fallback_location: root_path)
          }
          format.json { render json: {errors: ["Translation already exists"]}, status: :unprocessable_entity }
        end
        return
      end

      translation = Translation.new(translation_params)

      if translation.save
        respond_to do |format|
          format.html { redirect_to_translation_file(translation.file_path, notice: "Translation #{translation.key} was successfully created.") }
          format.json { render json: {message: "Translation created", translation: translation}, status: :ok }
        end
      else
        respond_to do |format|
          format.html {
            flash.now[:alert] = translation.errors.full_messages.join(", ")
            redirect_back(fallback_location: root_path)
          }
          format.json { render json: {errors: translation.errors.full_messages}, status: :unprocessable_entity }
        end
      end
    end

    def redirect_to_translation_file(file_path, notice: nil)
      respond_to do |format|
        format.html { redirect_to moirai_translation_file_path(Digest::SHA256.hexdigest(file_path)), notice: notice }
        format.json { render json: {message: notice} }
      end
    end

    def set_translation_file
      @file_path = @file_handler.file_hashes[params[:hashed_file_path]]
      if @file_path.nil?
        respond_to do |format|
          format.html {
            flash[:alert] = "File not found"
            redirect_to moirai_translation_files_path
          }
          format.json { render json: {errors: ["File not found"]}, status: :not_found }
        end
      end
    end

    def translation_params
      params.require(:translation).permit(:key, :locale, :value)
    end

    def load_file_handler
      @file_handler = Moirai::TranslationFileHandler.new
    end

    def translation_same_as_current?
      file_paths = KeyFinder.new.file_paths_for(translation_params[:key], locale: translation_params[:locale])

      return false if file_paths.empty?
      return false unless file_paths.all? { |file_path| File.exist?(file_path) }

      translation_params[:value] == @file_handler.parse_file(file_paths.first)[translation_params[:key]]
    end
  end
end
