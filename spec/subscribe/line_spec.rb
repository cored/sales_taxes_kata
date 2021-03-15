RSpec.describe Subscribe::Line do
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
