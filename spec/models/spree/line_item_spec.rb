RSpec.describe Spree::LineItem, type: :model do
  before do
    @order = create(:order, currency: 'USD')
    @variant = create(:variant, price: 10, currency: 'USD')
    @variant.volume_prices.create! amount: 9, discount_type: 'price', currency: 'USD', range: '(2+)'
    @order.contents.add(@variant, 1)
    @line_item = @order.line_items.first
    @role = create(:role)
  end

  it 'does not update the line item price when the variant role and order role don`t match' do
    expect(@order.user.has_spree_role? @role.name.to_sym).to be(false)
    @variant.volume_prices.first.update(role_id: @role.id)
    expect(@line_item.price.to_f).to be(10.00)
    @order.contents.add(@variant, 1)
    expect(@order.line_items.first.price.to_f).to be(10.00)
  end

end
