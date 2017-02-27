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
end