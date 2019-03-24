Spree::Variant.class_eval do

  has_and_belongs_to_many :volume_price_models
  has_many :volume_prices, -> { order(position: :asc) }, dependent: :destroy
  has_many :model_volume_prices, -> { order(position: :asc) }, class_name: 'Spree::VolumePrice', through: :volume_price_models, source: :volume_prices
  accepts_nested_attributes_for :volume_prices, allow_destroy: true,
    reject_if: proc { |volume_price|
      volume_price[:amount].blank? && volume_price[:range].blank?
    }

    def join_volume_prices(user=nil, currency=nil)
      table = Spree::VolumePrice.arel_table

      if user
        Spree::VolumePrice.where(
          (table[:variant_id].eq(self.id)
            .or(table[:volume_price_model_id].in(self.volume_price_models.ids)))
            .and(table[:role_id].eq(user.resolve_role.try(:id)))
            .and(table[:currency].eq(currency))
          ).order(position: :asc)
      else
        Spree::VolumePrice.where(
          (table[:variant_id]
            .eq(self.id)
            .or(table[:volume_price_model_id].in(self.volume_price_models.ids)))
            .and(table[:role_id].eq(nil))
            .and(table[:currency].eq(currency))
          ).order(position: :asc)
      end
    end

    # calculates the price based on quantity
    def volume_price(d_price, quantity, user=nil, currency=nil)
        compute_volume_price_quantities :volume_price, d_price, quantity, user, currency
    end

    protected


    def compute_volume_price_quantities type, default_price, quantity, user, currency
      volume_prices = self.join_volume_prices user, currency
      if volume_prices.count == 0
          return default_price
      else
        volume_prices.each do |volume_price|
          if volume_price.include?(quantity)
            return self.send "compute_#{type}".to_sym, volume_price
          end
        end
        # No price ranges matched.
        default_price
      end
    end

    def compute_volume_price volume_price
        return volume_price.amount
    end

end
