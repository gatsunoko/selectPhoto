class CreateConflicts < ActiveRecord::Migration[5.2]
  def change
    create_table :conflicts do |t|
      t.integer :picture_1, null: false, default: 0
      t.integer :picture_2, null: false, default: 0
      t.integer :count, null: false, default: 0

      t.timestamps
    end
  end
end
