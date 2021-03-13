module Subscribe
  extend self

  InvalidBasket = Class.new(StandardError)
  EXEMPT_PRODUCTS = ["book", "chocolate bar"]
  LINE_PATTERN = /(^\d+)\s(\w+)\sat\s(\d+$)/
  def call(line)
    raise InvalidBasket if line.to_s.empty?

    sale_taxes = 0.0
    quantity, product, price = line.scan(LINE_PATTERN).first

    price = price * 0.10 unless EXEMPT_PRODUCTS.include? product
    sale_taxes += price

    {
      products: [quantity: quantity, product: product, price: price],
      sale_taxes: sale_taxes,
      total: price
    }
  end

end

RSpec.describe Subscribe do
  subject(:subscribe) { described_class }

  context "when the basket is empty" do
    let(:baskets) { [nil, ""] }

    it "throws invalid basket error" do
      baskets.each do |basket|
        expect { subscribe.call(basket) }.to raise_error(described_class::InvalidBasket)
      end
    end
  end

  describe "Basic sale tax" do
    context "apply 10% tax to all good exept books, medicine and food" do
      let(:baskets)do
        {
          "2 book at 12.49" => {
            products: [{product: "book", quantity: 2, price: 24.98}],
            sale_taxes: 0.0,
            total: 24.98
          },
          "1 music CD at 14.99" => {
            products: [{product: "music CD", quantity: 1, price: 16.49}],
            sale_taxes: 1.50,
            total: 16.49
          },
          "1 chocolate bar at 14.99" => {
            products: [{product: "chocolate bar", quantity: 1, price: 0.85}],
            sale_taxes: 0.0,
            total: 0.85
          },
        }
      end

      it "return a receipt with the details" do
        baskets.each_pair do |basket, expectation|
          expect(
            subscribe.call(basket).to_h
          ).to match(expectation)
        end
      end
    end
  end
end
