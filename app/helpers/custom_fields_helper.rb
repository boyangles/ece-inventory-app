module CustomFieldsHelper
	def form_type(cf)
		case cf.field_type
			when 'short_text_type'
				return "text_field_tag"
			when 'long_text_type'
				return "text_area_tag"
			when 'integer_type' | 'float_type'
				return "number_field_tag"
		end
	end
end
