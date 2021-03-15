require_relative "./subscribe/sale_taxes"
require_relative "./subscribe/line"

module Subscribe
  extend self

  InvalidBasket = Class.new(StandardError)

  Receipt = Struct.new(:lines_with_taxes, keyword_init: true) do
    def self.for(lines)
      new(
        lines_with_taxes: lines.map { |line| SaleTaxes.for(line) }
      )
    end

    def to_h
      {
        products: products.map(&:to_h),
        sale_taxes: total_sale_taxes,
        total: total_price
      }
    end

    private

    def products
      lines_with_taxes
    end

    def total_sale_taxes
      lines_with_taxes.map(&:taxes).sum
    end

    def total_price
      lines_with_taxes.map(&:total_price).sum
    end

  end

  def call(line)
    raise InvalidBasket if line.to_s.empty?

    Receipt.for([Line.for(line)]).to_h
  end

end
