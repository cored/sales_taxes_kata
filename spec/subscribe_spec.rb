
RSpec.describe Subscribe do
  subject(:subscribe) { described_class }

  describe "Display receipt information for a list of items" do
    let(:baskets) do
      {
      %Q(2 book at 12.49
1 music CD at 14.99
1 chocolate bar at 0.85) => %Q(2 book: 24.98
1 music CD: 16.49
1 chocolate bar: 0.85
Sales Taxes: 1.50
Total: 42.32)
      }
    end

    it "prints items, sales taxes and total information" do
      baskets.each_pair do |basket, expectation|
        expect(subscribe.(basket).print).to eql(expectation)
      end
    end
  end
end
