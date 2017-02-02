module ItemsHelper
  def item_exists?(item_name)
    Item.find_by(:unique_name => item_name)
  end

  def item_quantity_sufficient?(request, item_name)
    item = Item.find_by(:unique_name => item_name)
    item.quantity - request.quantity >= 0
  end

  # function which adds tags to an item
  def add_tags_to_item(item, tags_to_add)
  	tags_to_add.each do |tag_id|
  	  if tag_id.present?
  		tag = Tag.find(tag_id)
  		item.tags << tag
  	  end
  	end
  end

  # function which removes tags from an item
  def remove_tags_from_item(item, tags_to_remove)
  	tags_to_remove.each do |tag_id|
  	  if tag_id.present?
  		tag = Tag.find(tag_id)
  		item.tags.delete(tag)
  	  end
  	end
  end
end
