RSpec.describe Subscribe::Receipt do
  subject(:receipt) { described_class }

  describe "#to_h" do
    let(:lines) do
      [
        Subscribe::Line.for("2 book at 12.49"),
        Subscribe::Line.for("1 music CD at 14.99"),
        Subscribe::Line.for("1 chocolate bar at 0.85"),
        Subscribe::Line.for("1 packet of headache pills at 9.75"),
        Subscribe::Line.for("1 imported box of chocolates at 10.00")
      ]
    end

    it "display sale tax price information for a list of lines" do
      expect(receipt.for(lines).to_h).to match(
        {
          products: [
            { product: "book", quantity: 2, taxes: 0.0, total_price: 24.98 },
            { product: "music CD", quantity: 1, taxes: 1.5, total_price: 16.49 },
            { product: "chocolate bar", quantity: 1, taxes: 0.0, total_price: 0.85},
            { product: "packet of headache pills", quantity: 1, taxes: 0.0, total_price: 9.75},
            { product: "imported box of chocolates", quantity: 1, taxes: 0.5, total_price: 10.50}
          ],
          sale_taxes: 2.0,
          total: 62.57
        }
      )

    end
  end
end
