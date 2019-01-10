FactoryBot.define do
  factory :picture do
    url { "MyString" }
    rating { 1 }
    user_id { 1 }
    win { 1 }
    lose { 1 }
    picture_present { false }
  end
end
