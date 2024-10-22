class CreateMoiraiTranslations < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :moirai_translations do |t|
      t.string :locale, null: false
      t.string :key, null: false
      t.text :value
      t.timestamps
    end
  end
end
