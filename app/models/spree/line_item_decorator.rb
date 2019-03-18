# frozen_string_literal: true
Spree::LineItem.class_eval do

  # Check to see if volume discounts are avalable in this currency
  def discounts_are_available
    if !(self.product.master.volume_prices.count == 0) && (self.variant.volume_price((self.quantity + 1), self.order.user, self.currency)) <= self.price
      true
    else
      false
    end
  end


  # Check to see line item quantity is grater than 1 and discounts are avalible.
  def discount_applied
    if variant && quantity > 1 && self.discounts_are_available
      true
    else
      false
    end
  end


  def pre_discount_price
    currency_price = Spree::Price.where(
      currency: order.currency,
      variant_id: variant_id
    ).first
    pre_discount_price = currency_price.price_including_vat_for(tax_zone: tax_zone)
  end


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


  def more_discounts_available
      if self.discounts_are_available && (self.variant.volume_price((self.quantity + 1), self.order.user, self.currency)) == self.price
        false
      else
        true
      end
  end

end
