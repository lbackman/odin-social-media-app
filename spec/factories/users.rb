FactoryBot.define do
  sequence :email do |n|
    "test_#{n}@email_provider.com"
  end

  factory :user do
    email
    password { 'pass123' }
    factory :user_with_info do
      after(:create) do |user, _evaluator|
        create(:user_information, user_id: user.id)

        # You may need to reload the record here, depending on your application
        user.reload
      end
    end
  end
end
