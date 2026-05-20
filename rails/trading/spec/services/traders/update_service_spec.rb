require "rails_helper"

RSpec.describe Traders::UpdateService do
  describe ".call" do
    let!(:trader) { Trader.create!(name: "Original Name", email: "test@example.com", balance: 50.0) }

    context "when the trader exists" do
      it "updates the trader's name" do
        result = described_class.call(email: "test@example.com", name: "New Name")
        expect(result.success?).to be true
        expect(result.data.reload.name).to eq("New Name")
      end
    end

    context "when the trader does not exist" do
      it "returns a failed result with error_type :not_found" do
        result = described_class.call(email: "non.existent@example.com", name: "New Name")
        expect(result.success?).to be false
        expect(result.error_type).to eq(:not_found)
        expect(result.errors).to include("Trader not found")
      end
    end
  end
end
