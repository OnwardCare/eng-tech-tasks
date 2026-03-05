class AddUniqueIndexToTradersEmail < ActiveRecord::Migration[7.0]
  def change
    add_index :traders, :email, unique: true
  end
end
