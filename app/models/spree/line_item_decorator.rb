# frozen_string_literal: true
Spree::LineItem.class_eval do

#### UTILTIY METHODS START #######
  # The default RRP price in the current order currency
  def pre_discount_price
    currency_price = Spree::Price.where(
      currency: order.currency,
      variant_id: variant_id
    ).first
    currency_price.price_including_vat_for(tax_zone: tax_zone)
  end

  # The current volume price in the current order currency
  def current_volume_price
    self.variant.volume_price(self.quantity, self.order.user, self.currency)
  end

  # Fetch the highest available volume discount price in the current currency, (if nill, no volume discounts are available.)

  def highest_volume_price
    self.product.master.volume_prices.where(:currency => order.currency).maximum(:amount)
  end

  # Fetch the lowest available volume discount price in the current currency, (if nill, no volume discounts are available.)
  def lowest_volume_price
      self.product.master.volume_prices.where(:currency => order.currency, :role_id => nil).minimum(:amount)
  end

  # Check to see if any volume discounts are available in this currency.
  def discounts_are_available
    if self.lowest_volume_price != nil
      true
    else
      false
    end
  end

  # Check to see if discount is applied.
  def discounts_are_applied
    if  self.discounts_are_available &&  self.current_volume_price <= self.highest_volume_price
      true
    else
      false
    end
  end

  # Check to see the maximum available discount has been reached
  def max_discount_reached
    if self.lowest_volume_price != nil && self.lowest_volume_price == self.price
      true
    else
      false
    end
  end
#### UTILTIY METHODS END #######

  def update_price
      copy_price
  end

  define_method(:copy_price) do
      # We only want to change the line item behavior if discounts are available in the order currency
      if self.discounts_are_applied
        if changed? && (changes.keys.include?('quantity') || changes.keys.include?('currency'))
          vprice = self.current_volume_price
          if self.price.present? && vprice <= self.variant.price
            self.price = vprice and return
          end
        end

        if self.price.nil?
          self.price = self.pre_discount_price
        end

      # Else we fallback to the default multiple currency behavior.
      else
        self.price = self.pre_discount_price
      end
  end

end
