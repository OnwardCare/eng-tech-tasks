class RemoveBalanceFromTraders < ActiveRecord::Migration[7.0]
  def change
    remove_column :traders, :balance, :float
  end
end
