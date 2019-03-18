# frozen_string_literal: true
Spree::LineItem.class_eval do

 # Fetch the lowest available volume discount price in the current currency, if nill, no volume discounts are available.
  def lowest_price
    lowest_price = self.product.master.volume_prices.where(:currency => order.currency).minimum(:amount)
  end

  # Check to see if any volume discounts are available in this currency.
  def discounts_are_available
    if self.lowest_price != nil && self.lowest_price <= self.price
      true
    else
      false
    end
  end

  # Check to see line item quantity is greater than 1 and discounts are available.
  def discount_applied
    if variant && quantity > 1 && self.discounts_are_available
      true
    else
      false
    end
  end

  # Check to see the maximum available discount has been reached
  def max_discount
    if self.lowest_price != nil && self.lowest_price == self.price
      true
    else
      false
    end
  end

  # The default RRP price in the current currency
  def pre_discount_price
    currency_price = Spree::Price.where(
      currency: order.currency,
      variant_id: variant_id
    ).first
    pre_discount_price = currency_price.price_including_vat_for(tax_zone: tax_zone)
  end



###### Below this line is where the volume pricing is applied (or not), depending on the results from the methods above.

  def update_price
    # We only want to change the line item behavior if cart items are in bulk (greater than 1)
    # and also if there are volume discounts available.
    if self.discount_applied
      copy_price

    # Else we fallback to the default multiple currency behavior.
    else
      currency_price = Spree::Price.where(
        currency: order.currency,
        variant_id: variant_id
      ).first
      self.price = currency_price.price_including_vat_for(tax_zone: tax_zone)
    end
  end

  define_method(:copy_price) do
      # We only want to change the line item behavior if cart items are in bulk (greater than 1)
      # and also if there are volume discounts available.
      if self.discount_applied

        if changed? && (changes.keys.include?('quantity') || changes.keys.include?('currency'))
          vprice = self.variant.volume_price(self.quantity, self.order.user, self.currency)
          if self.price.present? && vprice <= self.variant.price
            self.price = vprice and return
          end
        end

        if self.price.nil?
          self.price = self.variant.price
        end

      # Else we fallback to the default multiple currency behavior.
      else
        currency_price = Spree::Price.where(
          currency: order.currency,
          variant_id: variant_id
        ).first
        self.price = currency_price.price_including_vat_for(tax_zone: tax_zone)
      end
  end

end
