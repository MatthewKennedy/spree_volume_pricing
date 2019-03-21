RSpec.describe Spree::BaseHelper, type: :helper do
  include Spree::BaseHelper

  context 'volume pricing' do
    before do
      @variant = create :variant, price: 10
      @variant.volume_prices.create! amount: 5, discount_type: 'price', currency: 'USD',  range: '(10+)'
    end

    it 'gives discounted price' do
      expect(display_volume_price(@variant, 10)).to eq '$5.00'
    end
  end
end
