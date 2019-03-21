RSpec.describe Spree::LineItem, type: :model do
  before do
    @order = create(:order)
    @variant = create(:variant, price: 10)
    @variant.volume_prices.create! amount: 9, discount_type: 'price', currency: 'USD', range: '(2+)'
    @order.contents.add(@variant, 1)
    @line_item = @order.line_items.first
    @role = create(:role)
  end


end
