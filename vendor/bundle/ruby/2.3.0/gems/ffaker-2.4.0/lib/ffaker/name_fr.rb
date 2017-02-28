# encoding: utf-8

module FFaker
  # Author PapePathe<pathe.sene@gmail.com> github.com/PapePathe
  # The names & first names in this module were found at this url
  # https://github.com/fzaninotto/Faker/blob/master/src/Faker/Provider/fr_FR/Person.php
  module NameFR
    extend ModuleUtils
    extend self

    PREFIX = %w(de du le).freeze

    # randomized? (FRENCH)  prefix!
    #
    def prefix
      fetch_sample(PREFIX)
    end

    def last_name
      fetch_sample(LAST_NAMES)
    end

    def first_name
      fetch_sample(FIRST_NAMES)
    end

    def name
      case rand(10)
      when 7 then "#{first_name} #{prefix} #{last_name}"
      when 5 then "#{first_name} #{prefix} #{last_name}"
      when 3 then "#{first_name} #{last_name}"
      when 0 then "#{first_name} #{last_name}"
      else        "#{first_name} #{last_name}"
      end
    end
  end
end
