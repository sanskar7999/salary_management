require 'rails_helper'
RSpec.describe Employee, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:job_title) }
    it { should validate_presence_of(:country) }
    it { should validate_numericality_of(:salary).is_greater_than(0) }
  end

  describe 'full_name method' do
    it 'returns the correct full name' do
      employee = build(:employee)
      expect(employee.full_name).to eq("#{employee.first_name} #{employee.last_name}")
    end
  end
end