class BaseController < ApplicationController
  class << self
    Swagger::Docs::Generator::set_real_methods

    def inherited(subclass)
      super
      subclass.class_eval do
        setup_basic_api_documentation
      end
    end

    private
    def setup_basic_api_documentation
      [:index, :show, :create, :update, :destroy].each do |api_action|
        swagger_api api_action do
          param :header, :Authorization, :string, :required, 'Authentication token'
        end
      end
    end
  end

  def render_client_error(error_hash, status_number)
    render json: {
        errors: error_hash
    }, status: status_number
  end

  def enum_processable?(enum_value, possible_enums)
    return enum_value.blank? || possible_enums.include?(enum_value)
  end

  def all_tag_names_exist?(tag_filters)
    tag_filters.each do |t|
      if !Tag.exists?(:name => t)
        return false
      end
    end

    return true
  end

  def all_custom_field_names_exist?(custom_field_filters)
    custom_field_filters.each do |cf|
      return false unless CustomField.exists?(:field_name => cf)
    end

    return true
  end

  def key_value_query_string_to_hash_array(key_value_query)
    kv_pairs = (key_value_query.blank?) ? [] : key_value_query.split(",").map(&:strip)
    my_result = []

    kv_pairs.each do |kv|
      my_pairs = (kv.blank?) ? [] : kv.split(":").map(&:strip)
      if my_pairs.length < 2
        return [], "Not enough colons in entry in query #{kv}"
      elsif my_pairs.length > 2
        return [], "Too many colons in query #{kv}"
      else
        my_result.push({
          :key => my_pairs[0],
          :value => my_pairs[1]
        })
      end
    end

    return my_result, nil
  end
end