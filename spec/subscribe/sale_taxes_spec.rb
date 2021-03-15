RSpec.describe Subscribe::SaleTaxes do
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
