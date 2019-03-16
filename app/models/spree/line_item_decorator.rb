# frozen_string_literal: true

Spree::LineItem.class_eval do

  def update_price

    copy_price
  end

  old_copy_price = instance_method(:copy_price)
  define_method(:copy_price) do

    if variant
      if changed? && (changes.keys.include?('quantity') || changes.keys.include?('currency'))
        vprice = self.variant.volume_price(self.quantity, self.order.user, self.currency)
        if self.price.present? && vprice <= self.variant.price
          self.price = vprice and return
        end
      end

      if self.price.nil?
        self.price = self.variant.price
      end
    end
  end

end
