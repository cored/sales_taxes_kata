module Subscribe
  SaleTaxes = Struct.new(:line, :tax, keyword_init: true) do
    SALE_TAX = 0.10
    IMPORT_TAX = 0.05

    PRECISION_RATE = 0.05

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
      format("%.2f", ( (line.total * tax) / PRECISION_RATE).ceil * PRECISION_RATE).to_f
    end
  end
end
