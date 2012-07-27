require 'faker'
FactoryGirl.define do
  factory :bookmark do |f|
    f.full_url {Faker::Internet.domain_name + "/testing?q=12345&time=20120302"}
  end
end