# encoding: utf-8

module FFaker
  module Boolean
    extend ModuleUtils
    extend self

    def maybe
      case rand(2)
      when 0 then true
      when 1 then false
      end
    end

    alias random maybe
    alias sample maybe
  end
end
