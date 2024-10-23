class CreateMoiraiTranslations < ActiveRecord::Migration[7.2]
  def change
    create_table :moirai_translations do |t|
      t.string :file_path, null: false
      t.string :key, null: false
      t.text :value
      t.timestamps
    end
  end
end
