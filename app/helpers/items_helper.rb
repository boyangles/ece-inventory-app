module ItemsHelper
  def item_exists?(item_name)
    Item.find_by(:unique_name => item_name)
  end

  def item_quantity_sufficient?(request, item_name)
    item = Item.find_by(:unique_name => item_name)
    item.quantity - request.quantity >= 0
  end
end
