class TraderTransaction < ActiveRecord::Migration[7.0]
  def change
    create_table :trader_transactions do |t|
      t.references :trader
      t.decimal :amount, precision: 8, scale: 2

      t.timestamps
    end
  end
end
