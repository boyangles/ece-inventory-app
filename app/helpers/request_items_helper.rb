module RequestItemsHelper
	def get_active_backfill(req_item)
		designated_bf

		req_item.backfills.each do |bf| 
			if bf.in_cart? || bf.outstanding? 
				designated_bf = bf
			end
		end

		if designated_bf.nil?
			designated_bf = Backfill.new(:request_item_id => req_item.id, :bf_status => "in-cart")
			designated_bf.save!
		end

		return designated_bf
	end

	def get_active_bf_quantity(req_item)
		bf_quantity = 0

		req_item.backfills.each do |bf|
			if !bf.failed?
				bf_quantity = bf_quantity + bf.quantity
			end
		end
	
		return bf_quantity
	end
end
