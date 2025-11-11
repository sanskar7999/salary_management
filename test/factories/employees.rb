FactoryBot.define do
  factory :employee do
    first_name { "John" }
    last_name  { "Doe" }
    country { "USA" }
    job_title { "Developer" }
    salary { 60000 }
  end
end
