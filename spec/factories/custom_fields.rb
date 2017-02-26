FactoryGirl.define do
  factory :custom_field do
    field_name { FFaker::Name.name }

    factory :field_private_short_text do
      private_indicator true
      field_type 'short_text_type'
    end

    factory :field_private_long_text do
      private_indicator true
      field_type 'long_text_type'
    end

    factory :field_private_integer do
      private_indicator true
      field_type 'integer_type'
    end

    factory :field_private_float do
      private_indicator true
      field_type 'float_type'
    end

    factory :field_public_short_text do
      private_indicator false
      field_type 'short_text_type'
    end

    factory :field_public_long_text do
      private_indicator false
      field_type 'long_text_type'
    end

    factory :field_public_integer do
      private_indicator false
      field_type 'integer_type'
    end

    factory :field_public_float do
      private_indicator false
      field_type 'float_type'
    end
  end
end
