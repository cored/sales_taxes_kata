module Subscribe
  extend self

  InvalidBasket = Class.new(StandardError)
  EXEMPT_PRODUCTS = ["book", "chocolate bar"]
  SALE_TAX = 0.10

  Line = Struct.new(:quantity, :product, :price, keyword_init: true) do
    LINE_PATTERN = /^(\d+)\s(.+)\sat\s(\d+\.\d+)$/
    def self.for(line)
      quantity, product, price = line.scan(LINE_PATTERN).first
      new(quantity: quantity.to_i, product: product, price: price.to_f)
    end

    def total
      price * quantity
    end
  end

  SaleTaxes = Struct.new(:tax, :total, keyword_init: true) do
    def self.for(line)
      tax = line.price * SALE_TAX unless EXEMPT_PRODUCTS.include? line.product

      new(tax: ("%.2f" % [tax.to_f]).to_f, total: ("%.2f" % [line.total + tax.to_f]).to_f)
    end
  end

  def call(line)
    raise InvalidBasket if line.to_s.empty?

    line = Line.for(line)

    sale_taxes = SaleTaxes.for(line)

    {
      products: [quantity: line.quantity, product: line.product, price: sale_taxes.total],
      sale_taxes: sale_taxes.tax,
      total: sale_taxes.total
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
            sale_taxes: 0.00,
            total: 24.98
          },
          "1 music CD at 14.99" => {
            products: [{product: "music CD", quantity: 1, price: 16.49}],
            sale_taxes: 1.50,
            total: 16.49
          },
          "1 chocolate bar at 0.85" => {
            products: [{product: "chocolate bar", quantity: 1, price: 0.85}],
            sale_taxes: 0.00,
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
