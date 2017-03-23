module ItemsHelper
	def item_exists?(item_name)
		Item.find_by(:unique_name => item_name)
	end

	def item_quantity_sufficient?(request, item_name)
		item = Item.find_by(:unique_name => item_name)
		item.quantity - request.quantity >= 0
	end

	# function which adds tags to an item
	# DEPRECATED
	# def add_tags_to_item(item, tags_to_add)
	# tags_to_add.each do |tag_id|
	#   if tag_id.present?
	# 	tag = Tag.find(tag_id)
	# 	item.tags << tag
	#   end
	# end
	# end

	# function which removes tags from an item
	# DEPRECATED
	# def remove_tags_from_item(item, tags_to_remove)
	# tags_to_remove.each do |tag_id|
	#   if tag_id.present?
	# 	tag = Tag.find(tag_id)
	# 	item.tags.delete(tag)
	#   end
	# end
	# end

	def add_tags_to_item(item)
		puts item.unique_name

		# if item.tag_list != nil
			if item.tag_list.include? ','
				tags = item.tag_list.split(',')
				tags.each do |name|
					tag = Tag.find_or_create_by(name: name)
					item.tags << tag
				end
			else
				item.tags << Tag.find_or_create_by(name: item.tag_list)
			end
		# end
	end



end
