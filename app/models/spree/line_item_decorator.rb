# frozen_string_literal: true
Spree::LineItem.class_eval do

  def update_price
    if quantity > 1
      copy_price
    else
      currency_price = Spree::Price.where(
        currency: order.currency,
        variant_id: variant_id
      ).first

      self.price = currency_price.price_including_vat_for(tax_zone: tax_zone)
    end
  end

  define_method(:copy_price) do

      if variant && quantity > 1

        if changed? && (changes.keys.include?('quantity') || changes.keys.include?('currency'))
          vprice = self.variant.volume_price(self.quantity, self.order.user, self.currency)
          if self.price.present? && vprice <= self.variant.price
            self.price = vprice and return
          end
        end

        if self.price.nil?
          self.price = self.variant.price
        end

      else
        currency_price = Spree::Price.where(
          currency: order.currency,
          variant_id: variant_id
        ).first

        self.price = currency_price.price_including_vat_for(tax_zone: tax_zone)
      end
  end

end
