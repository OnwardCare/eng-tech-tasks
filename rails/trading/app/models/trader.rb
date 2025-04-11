class Trader < ApplicationRecord
  scope :ordered, -> { order(:id) }

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def add_balance(amount)
    self.balance += amount.to_f
    save
  end
end
