class CreateCabins < ActiveRecord::Migration[8.0]
  def change
    create_table :cabins do |t|
      t.string :name
      t.decimal :price_per_night
      t.integer :capacity
      t.string :location

      t.timestamps
    end
  end
end
