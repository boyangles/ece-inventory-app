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
end