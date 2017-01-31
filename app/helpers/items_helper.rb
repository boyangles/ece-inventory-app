module ItemsHelper
  def itemExists?(item_id)
    Item.find_by(:id => item_id)
  end

  def itemQuantitySufficient?(@request, item_id)
    item = Item.find_by(:id => item_id)
    item.quantity - @request.quantity >= 0
  end
end
