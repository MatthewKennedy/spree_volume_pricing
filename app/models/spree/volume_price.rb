class Spree::VolumePrice < Spree::Base

  belongs_to :variant, touch: true, required: true
  belongs_to :volume_price_model, touch: true, required: false
  belongs_to :spree_role, class_name: 'Spree::Role', foreign_key: 'role_id', required: false

  acts_as_list scope: [:variant_id, :volume_price_model_id]

  validates :amount, presence: true
  validates :discount_type,
            presence: true,
            inclusion: {
              in: %w(price),
              message: I18n.t(:'activerecord.errors.messages.is_not_included_in_the_list')
            }
  validates :range,
            format: {
              with: /\(?[0-9]+(?:\.{2,3}[0-9]+|\+\)?)/,
              message: I18n.t(:'activerecord.errors.messages.must_be_in_format')
            }

  OPEN_ENDED = /\(?[0-9]+\+\)?/

  def include?(quantity)
    if open_ended?
      bound = /\d+/.match(range)[0].to_i
      return quantity >= bound
    else
      range.to_range === quantity
    end
  end

  # indicates whether or not the range is a true Ruby range or an open ended range with no upper bound
  def open_ended?
    OPEN_ENDED =~ range
  end

end
