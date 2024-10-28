class MakeMoiraiTranslationsFilePathNotRequired < ActiveRecord::Migration[7.2]
  def change
    change_column_null :moirai_translations, :file_path, true
  end
end
