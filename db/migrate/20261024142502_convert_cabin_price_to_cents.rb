class ConvertCabinPriceToCents < ActiveRecord::Migration[8.1]
  REQUIRED_COLUMNS = %i[name location capacity price_per_night_cents].freeze

  def up
    add_column :cabins, :price_per_night_cents, :integer
    execute "UPDATE cabins SET price_per_night_cents = ROUND(price_per_night * 100)"
    remove_column :cabins, :price_per_night

    REQUIRED_COLUMNS.each { |column| change_column_null :cabins, column, false }
  end

  def down
    REQUIRED_COLUMNS.each { |column| change_column_null :cabins, column, true }

    add_column :cabins, :price_per_night, :decimal
    execute "UPDATE cabins SET price_per_night = price_per_night_cents / 100.0"
    remove_column :cabins, :price_per_night_cents
  end
end
