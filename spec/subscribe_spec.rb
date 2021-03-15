module Subscribe
  extend self

  InvalidBasket = Class.new(StandardError)

  Line = Struct.new(:quantity, :product, :price, keyword_init: true) do
    LINE_PATTERN = /^(\d+)\s(.+)\sat\s(\d+\.\d+)$/
    EXEMPT_PRODUCTS = ["book", "chocolate bar", "packet of headache pills", "box of chocolates"]

    def self.for(line)
      quantity, product, price = line.scan(LINE_PATTERN).first
      raise ArgumentError if quantity.to_s.empty? || price.to_s.empty?  || product.to_s.empty?

      new(quantity: quantity.to_i, product: product, price: price.to_f)
    end

    def total
      price * quantity
    end

    def exempt?
      EXEMPT_PRODUCTS.include? product.gsub(/^imported\s/, '')
    end

    def imported?
      product.include? "imported"
    end

    def to_h
      {
        product: product,
        price: total,
        quantity: quantity,
      }
    end
  end

  SaleTaxes = Struct.new(:line, :tax, keyword_init: true) do
    SALE_TAX = 0.10
    IMPORT_TAX = 0.05

    def self.for(line)
      sale_rate = SALE_TAX unless line.exempt?
      import_rate = IMPORT_TAX if line.imported?

      new(line: line, tax: ("%.2f" % [sale_rate.to_f + import_rate.to_f]).to_f)
    end

    def to_h
      {
        product: product,
        total_price: total_price,
        quantity: quantity,
        taxes: taxes,
      }
    end

    def total_price
      format("%.2f", taxes + line.total).to_f
    end

    def quantity
      line.quantity
    end

    def product
      line.product
    end

    def price
      line.price
    end

    def taxes
      format("%.2f", ((line.total * tax) / 0.05).round * 0.05).to_f
    end
  end

  def call(line)
    raise InvalidBasket if line.to_s.empty?
    line = Line.for(line)

    line_sale_taxes = SaleTaxes.for(line)

    {
      products: [line_sale_taxes.to_h],
      sale_taxes: line_sale_taxes.taxes,
      total: line_sale_taxes.total_price
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
            products: [{product: "book", quantity: 2, total_price: 24.98, taxes: 0.0}],
            sale_taxes: 0.00,
            total: 24.98
          },
          "1 music CD at 14.99" => {
            products: [{product: "music CD", quantity: 1, total_price: 16.49, taxes: 1.5}],
            sale_taxes: 1.50,
            total: 16.49
          },
          "1 chocolate bar at 0.85" => {
            products: [{product: "chocolate bar", quantity: 1, total_price: 0.85, taxes: 0.0}],
            sale_taxes: 0.00,
            total: 0.85
          },
          "1 packet of headache pills at 9.75" => {
            products: [{product: "packet of headache pills", quantity: 1, total_price: 9.75, taxes: 0.0}],
            sale_taxes: 0.00,
            total: 9.75
          },
          "1 bottle of perfume at 18.99" => {
            products: [{product: "bottle of perfume", quantity: 1, total_price: 20.89, taxes: 1.9}],
            sale_taxes: 1.90,
            total: 20.89
          }
        }
      end

      it "return a receipt with the details" do
        baskets.each_pair do |basket, expectation|
          expect(subscribe.call(basket).to_h).to match(expectation)
        end
      end
    end

    describe "Imported sale tax" do
      context "apply 5% to all imported goods without exceptions" do
        let(:baskets) do
          {
            "1 imported box of chocolates at 10.00" => {
              products: [{product: "imported box of chocolates", quantity: 1, total_price: 10.50, taxes: 0.5}],
              sale_taxes: 0.5,
              total: 10.50
            }
          }
        end

        it "return a receipt with the details" do
          baskets.each_pair do |basket, expectation|
            expect(subscribe.call(basket).to_h).to match(expectation)
          end
        end
      end
    end
  end

  describe Subscribe::Line do
    subject(:line) { described_class }

    describe '.for' do
      it 'throws an argument error for empty lines' do
        expect { line.for("''") }.to raise_error(ArgumentError)
      end

      context 'when passing non empty lines' do
        let(:lines) do
          {
            "2 book at 12.49" => {product: "book", quantity: 2, price: 24.98},
            "1 music CD at 14.99" => {product: "music CD", quantity: 1, price: 14.99},
            "1 chocolate bar at 0.85" => {product: "chocolate bar", quantity: 1, price: 0.85}
          }
        end

        it 'returns a valid line' do
          lines.each_pair do |attributes, expectation|
            expect(line.for(attributes).to_h).to match(expectation)
          end
        end
      end
    end

    describe "#exempt?" do
      context 'when the product is book, medicine or food' do
        let(:lines) do
          [
            "1 book at 10.00",
            "1 chocolate bar at 5.00",
            "1 packet of headache pills at 3.00"
          ]
        end

        it 'returns `true` for exempt product' do
          lines.each do |attributes|
            expect(line.for(attributes)).to be_exempt
          end
        end
      end

      context 'when the product is not a book, medicine or food' do
        let(:lines) do
          [
            "1 music CD at 10.00",
            "1 bottle of perfume at 20.00",
          ]
        end

        it 'returns `false` for exempt product' do
          lines.each do |attributes|
            expect(line.for(attributes)).not_to be_exempt
          end
        end
      end

    end

    describe "#imported?" do
      it "returns `true` for imported products" do
        expect(line.for("1 imported box of chocolates at 3.00")).to be_imported
      end

      it "returns `false` for non-imported products" do
        expect(line.for("1 box of chocolates at 3.00")).not_to be_imported
      end
    end
  end

  describe Subscribe::SaleTaxes do
    subject(:sale_taxes) { described_class }

    describe '.for' do
      context 'when passing general goods' do
        let(:lines) do
          {
            Subscribe::Line.new(quantity: 1, product: "music CD", price: 14.99) => {
              quantity: 1, product: "music CD", total_price: 16.49, taxes: 1.50
            },
            Subscribe::Line.new(quantity: 1, product: "bottle of perfume", price: 18.99) => {
              quantity: 1, product: "bottle of perfume", total_price: 20.89, taxes: 1.90
            }
          }
        end

        it 'apply 10% tax' do
          lines.each_pair do |line, expectation|
            expect(sale_taxes.for(line).to_h).to match(expectation)
          end
        end
      end
    end

    context 'when passing food, books or medicine' do
      let(:lines) do
        {
          Subscribe::Line.new(quantity: 1, product: "book", price: 12.49) => {
            quantity: 1, product: "book", total_price: 12.49, taxes: 0.0
          },
          Subscribe::Line.new(quantity: 1, product: "chocolate bar", price: 0.85) => {
            quantity: 1, product: "chocolate bar", total_price: 0.85, taxes: 0.0,
          },
          Subscribe::Line.new(quantity: 1, product: "packet of headache pills", price: 9.75) => {
            quantity: 1, product: "packet of headache pills", total_price: 9.75, taxes: 0.0
          },
        }
      end

      it 'does not apply 10% tax' do
        lines.each_pair do |line, expectation|
          expect(sale_taxes.for(line).to_h).to match(expectation)
        end
      end
    end

    context "when passing imported lines" do
      let(:lines) do
        {
          Subscribe::Line.new(quantity: 1, product: "imported box of chocolates", price: 10.00) => {
            quantity: 1, product: "imported box of chocolates", total_price: 10.50, taxes: 0.5
          },
          Subscribe::Line.new(quantity: 1, product: "imported bottle of perfume", price: 47.50) => {
            quantity: 1, product: "imported bottle of perfume", total_price: 54.65, taxes: 7.15
          },
        }
      end

      it 'apply 5% tax' do
        lines.each_pair do |line, expectation|
          expect(sale_taxes.for(line).to_h).to match(expectation)
        end
      end

    end
  end

end
