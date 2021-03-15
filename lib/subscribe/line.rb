module Subscribe
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
end
