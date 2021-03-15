
RSpec.describe Subscribe do
  subject(:subscribe) { described_class }

  # context "when the basket is empty" do
  #   let(:baskets) { [nil, ""] }

  #   it "throws invalid basket error" do
  #     baskets.each do |basket|
  #       expect { subscribe.call(basket) }.to raise_error(described_class::InvalidBasket)
  #     end
  #   end
  # end

  # describe "Basic sale tax" do
  #   context "apply 10% tax to all good exept books, medicine and food" do
  #     let(:baskets)do
  #       {
  #         "2 book at 12.49" => {
  #           products: [{product: "book", quantity: 2, total_price: 24.98, taxes: 0.0}],
  #           sale_taxes: 0.00,
  #           total: 24.98
  #         },
  #         "1 music CD at 14.99" => {
  #           products: [{product: "music CD", quantity: 1, total_price: 16.49, taxes: 1.5}],
  #           sale_taxes: 1.50,
  #           total: 16.49
  #         },
  #         "1 chocolate bar at 0.85" => {
  #           products: [{product: "chocolate bar", quantity: 1, total_price: 0.85, taxes: 0.0}],
  #           sale_taxes: 0.00,
  #           total: 0.85
  #         },
  #         "1 packet of headache pills at 9.75" => {
  #           products: [{product: "packet of headache pills", quantity: 1, total_price: 9.75, taxes: 0.0}],
  #           sale_taxes: 0.00,
  #           total: 9.75
  #         },
  #         "1 bottle of perfume at 18.99" => {
  #           products: [{product: "bottle of perfume", quantity: 1, total_price: 20.89, taxes: 1.9}],
  #           sale_taxes: 1.90,
  #           total: 20.89
  #         }
  #       }
  #     end

  #     it "return a receipt with the details" do
  #       baskets.each_pair do |basket, expectation|
  #         expect(subscribe.call(basket).to_h).to match(expectation)
  #       end
  #     end
  #   end

  #   describe "Imported sale tax" do
  #     context "apply 5% to all imported goods without exceptions" do
  #       let(:baskets) do
  #         {
  #           "1 imported box of chocolates at 10.00" => {
  #             products: [{product: "imported box of chocolates", quantity: 1, total_price: 10.50, taxes: 0.5}],
  #             sale_taxes: 0.5,
  #             total: 10.50
  #           }
  #         }
  #       end

  #       it "return a receipt with the details" do
  #         baskets.each_pair do |basket, expectation|
  #           expect(subscribe.call(basket).to_h).to match(expectation)
  #         end
  #       end
  #     end
  #   end
  # end
end
