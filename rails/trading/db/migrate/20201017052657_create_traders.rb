class CreateTraders < ActiveRecord::Migration[6.0]
  def change
    create_table :traders do |t|
      t.string :name
      t.string :email
      t.float :balance

      t.timestamps
    end
  end
end
