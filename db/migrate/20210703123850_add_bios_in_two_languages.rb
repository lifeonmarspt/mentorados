class AddBiosInTwoLanguages < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :bio_en, :text
    rename_column :users, :bio, :bio_pt
  end
end
