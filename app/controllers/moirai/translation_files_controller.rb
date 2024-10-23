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
    end

    def create_or_update
      if (translation = Translation.find_by(file_path: existing_or_invented_path(translation_params[:file_path]), key: translation_params[:key]))
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

    def existing_or_invented_path(file_path)
      File.exist?(file_path) ? file_path : invent_file_path(translation_params[:key], I18n.locale)
    end

    def handle_update(translation)
      if translation.value.strip.blank?
        translation.destroy
        flash.notice = "Translation #{translation.key} was successfully deleted."
        redirect_to_translation_file(translation.file_path)
        return
      end

      if File.exist? translation_params[:file_path]
        translation_from_file = @file_handler.parse_file(translation_params[:file_path])
        if translation_from_file[translation.key].strip == translation_params[:value].strip
          translation.destroy
          flash.notice = "Translation #{translation.key} was successfully deleted."
          redirect_to_translation_file(translation.file_path)
          return
        end
      end

      if translation.update(value: translation_params[:value])
        flash.notice = "Translation #{translation.key} was successfully updated."
      else
        flash.alert = translation.errors.full_messages.join(", ")
      end

      redirect_to_translation_file(translation.file_path)
    end

    def handle_create
      if File.exist?(translation_params[:file_path])
        translation_from_file = @file_handler.parse_file(translation_params[:file_path])
        if translation_from_file[translation_params[:key]] == translation_params[:value]
          flash.alert = "Translation #{translation_params[:key]} already exist."
          redirect_to_translation_file(translation_params[:file_path])
          return
        end
      end

      translation = Translation.new(translation_params.merge(locale: I18n.locale)) # TODO: remove locale
      translation.file_path = existing_or_invented_path(translation.file_path)

      if translation.save!
        flash.notice = "Translation #{translation.key} was successfully created."
      else
        Rails.logger.error(translation.errors.full_messages)
        flash.alert = translation.errors.full_messages.join(", ")
      end

      redirect_to_translation_file(translation.file_path)
    end

    def invent_file_path(locale, key)
      Rails.root.join("config", "locales", "moirai_#{locale}_#{key}.yml").to_s
    end

    def redirect_to_translation_file(file_path)
      redirect_back_or_to moirai_translation_file_path(Digest::SHA256.hexdigest(file_path))
    end

    def set_translation_file
      @file_path = @file_handler.file_hashes[params[:id]]
      @decoded_path = CGI.unescape(@file_path)
    end

    def translation_params
      params.require(:translation).permit(:key, :value, :file_path)
    end

    def load_file_handler
      @file_handler = Moirai::TranslationFileHandler.new
    end
  end
end
