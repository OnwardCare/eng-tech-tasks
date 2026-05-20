require "rails_helper"

RSpec.describe Traders::RegisterService do
  describe ".call" do
    let(:params) { { name: "Test Trader", email: "test@example.com", balance: 100.0 } }

    context "with valid parameters" do
      it "registers a new trader" do
        expect do
          result = described_class.call(**params)
          expect(result.success?).to be true
          expect(result.data).to be_a(Trader)
          expect(result.data.email).to eq("test@example.com")
        end.to change(Trader, :count).by(1)
      end
    end

    context "when the email already exists" do
      before do
        Trader.create!(name: "Existing", email: "test@example.com", balance: 0.0)
      end

      it "returns a failure result with an error message" do
        expect do
          result = described_class.call(**params)
          expect(result.success?).to be false
          expect(result.errors).to include("Email has already been taken")
        end.not_to change(Trader, :count)
      end
    end
  end
end
