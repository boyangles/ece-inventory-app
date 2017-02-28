# encoding: utf-8

module FFaker
  # Author PapePathe<pathe.sene@gmail.com> github.com/PapePathe
  # The names & first names in this module were found at this url:
  # http://www.senegalaisement.com/senegal/noms_et_prenoms.html
  module NameSN
    extend ModuleUtils
    extend self

    PREFIX_FEMALE = %w(adja adjaratou mame ndeye).freeze
    PREFIX_MALE = %w(pape eladji mame serigne).freeze

    def last_name
      fetch_sample(LAST_NAMES)
    end

    def first_name_male
      fetch_sample(FIRST_NAMES_MALE)
    end

    def first_name_female
      fetch_sample(FIRST_NAMES_FEMALE)
    end

    def prefix_male
      fetch_sample(PREFIX_MALE)
    end

    def prefix_female
      fetch_sample(PREFIX_FEMALE)
    end

    def name_male
      case rand(10)
      when 7 then "#{prefix_male} #{first_name_male} #{last_name}"
      when 5 then "#{prefix_male} #{first_name_male} #{last_name}"
      when 3 then "#{first_name_male} #{last_name}"
      when 0 then "#{first_name_male} #{last_name}"
      else        "#{first_name_male} #{last_name}"
      end
    end

    def name_female
      case rand(10)
      when 7 then "#{prefix_female} #{first_name_female} #{last_name}"
      when 5 then "#{prefix_female} #{first_name_female} #{last_name}"
      when 3 then "#{first_name_female} #{last_name}"
      when 0 then "#{first_name_female} #{last_name}"
      else        "#{first_name_female} #{last_name}"
      end
    end

    def name_sn
      case rand(10)
      when 7 then "#{prefix_female} #{first_name_female} #{last_name}"
      when 5 then "#{prefix_male} #{first_name_male} #{last_name}"
      when 3 then "#{first_name_male} #{last_name}"
      when 3 then "#{first_name_female} #{last_name}"
      when 0 then "#{first_name_male} #{last_name}"
      else        "#{first_name_female} #{last_name}"
      end
    end
  end
end
