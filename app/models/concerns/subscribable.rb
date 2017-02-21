module Subscribable
  extend ActiveSupport::Concern

  # CONSTANTS:
  REQUEST_TYPE_OPTIONS = %w(disbursement acquisition destruction)

  module ClassMethods
    def component_oversubscribed?(item, superscription, subscription)
      quantity_diff = item[:quantity] - subscription[:quantity]

      case superscription[:request_type]
        when 'disbursement'
          return quantity_diff < 0
        when 'acquisition'
          return false
        when 'destruction'
          return quantity_diff < 0
        else
          return false
      end
    end

    def oversubscribed?(item, subscription)
      quantity_diff = item[:quantity] - subscription[:quantity]
    
      case subscription[:request_type]
      when 'disbursement'
        return quantity_diff < 0
      when 'acquisition'
        return false
      when 'destruction'
        return quantity_diff < 0
      else
        return false
      end
    end
  end
end
