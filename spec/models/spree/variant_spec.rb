RSpec.describe Spree::Variant, type: :model do
  it { is_expected.to have_many(:volume_prices) }

  describe '#volume_price' do

    context 'discount_type = price' do
      before :each do
        @variant = create :variant, price: 10
        @variant.volume_prices.create! amount: 9, discount_type: 'price', currency: 'USD', range: '(10+)'
        @role = create(:role)
        @user = create(:user)
      end

    end
  end
end
