class CreateRoutine < ActiveRecord::Migration[5.0]
  def change
    create_table :routines do |t|
      t.string :title, null: false
      t.string :source, null: false
      t.timestamps
    end
  end
end
