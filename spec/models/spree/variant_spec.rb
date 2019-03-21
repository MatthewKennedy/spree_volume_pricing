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

      it 'uses the variants price when it does not match a range' do
        expect(@variant.volume_price(1).to_f).to be(10.00)
      end

      it 'uses the variants price when it does not match role with null role' do
        @variant.volume_prices.first.update(role_id: @role.id)
        expect(@variant.volume_price(10).to_f).to be(10.00)
      end

      it 'uses the variants price when it does not match roles' do
        other_role = create(:role)
        @user.spree_roles << other_role
        @variant.volume_prices.first.update(role_id: @role.id)
        expect(@variant.volume_price(10, @user).to_f).to be(10.00)
      end

      it 'uses the volume price when it does match a range' do
        expect(@variant.volume_price(10).to_f).to be(9.00)
      end

      it 'uses the volume price when it does match a range and role' do
        @user.spree_roles << @role
        Spree::Config.volume_pricing_role = @role.name
        @variant.volume_prices.first.update(role_id: @role.id)
        expect(@variant.volume_price(10, @user).to_f).to be(9.00)
      end

    end
  end
end
