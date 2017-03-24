module ItemsHelper
	def item_exists?(item_name)
		Item.find_by(:unique_name => item_name)
	end

	def item_quantity_sufficient?(request, item_name)
		item = Item.find_by(:unique_name => item_name)
		item.quantity - request.quantity >= 0
	end


	def add_tags_to_item(item, item_params)
		item.tag_list = item_params[:tag_list]
		item.tag_list.each do |tag_name|
			unless tag_name.blank?
				@item.tags << Tag.find_or_create_by(name: tag_name)
			end
		end
	end



end
