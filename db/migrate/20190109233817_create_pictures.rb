class CreatePictures < ActiveRecord::Migration[5.2]
  def change
    create_table :pictures do |t|
      t.string :url
      t.integer :rating, default: 1500, null: false
      t.integer :user_id
      t.integer :win, default: 0, null: false
      t.integer :lose, default: 0, null: false
      t.boolean :picture_present, default: true, null: false

      t.timestamps
    end
  end
end
