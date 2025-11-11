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

  describe '#tds_rate_for_country' do
    it 'returns 0.10 for India' do
      employee = build(:employee, country: 'India')
      expect(employee.tds_rate_for_country).to eq(0.10)
    end

    it 'returns 0.12 for United States' do
      employee = build(:employee, country: 'United States')
      expect(employee.tds_rate_for_country).to eq(0.12)
    end

    it 'returns 0.12 for USA' do
      employee = build(:employee, country: 'USA')
      expect(employee.tds_rate_for_country).to eq(0.12)
    end

    it 'returns 0.0 for other countries' do
      employee = build(:employee, country: 'Canada')
      expect(employee.tds_rate_for_country).to eq(0.0)
    end

    it 'handles case-insensitive country matching' do
      employee = build(:employee, country: 'INDIA')
      expect(employee.tds_rate_for_country).to eq(0.10)
    end
  end

  describe '#calculate_deductions' do
    it 'calculates correct deductions for India (10% TDS)' do
      employee = create(:employee, country: 'India')
      result = employee.calculate_deductions(1000)

      expect(result[:employee_id]).to eq(employee.id)
      expect(result[:country]).to eq('India')
      expect(result[:gross_salary]).to eq(1000.0)
      expect(result[:tds]).to eq(100.0)
      expect(result[:net_salary]).to eq(900.0)
    end

    it 'calculates correct deductions for United States (12% TDS)' do
      employee = create(:employee, country: 'United States')
      result = employee.calculate_deductions(1000)

      expect(result[:country]).to eq('United States')
      expect(result[:tds]).to eq(120.0)
      expect(result[:net_salary]).to eq(880.0)
    end

    it 'returns no deductions for other countries' do
      employee = create(:employee, country: 'Canada')
      result = employee.calculate_deductions(500)

      expect(result[:tds]).to eq(0.0)
      expect(result[:net_salary]).to eq(500.0)
    end

    it 'handles string and numeric gross salary inputs' do
      employee = create(:employee, country: 'India')
      result1 = employee.calculate_deductions('1000')
      result2 = employee.calculate_deductions(1000)

      expect(result1[:tds]).to eq(result2[:tds])
      expect(result1[:net_salary]).to eq(result2[:net_salary])
    end

    it 'rounds values to 2 decimal places' do
      employee = create(:employee, country: 'India')
      result = employee.calculate_deductions(333.33)

      expect(result[:tds]).to eq(33.33)
      expect(result[:net_salary]).to eq(300.0)
    end
  end

  describe '.salary_metrics_by_country' do
    before do
      create(:employee, country: 'India', salary: 1000)
      create(:employee, country: 'India', salary: 2000)
      create(:employee, country: 'India', salary: 3000)
      create(:employee, country: 'USA', salary: 5000)
    end

    it 'returns min, max, and average salary for a country' do
      result = Employee.salary_metrics_by_country('India')

      expect(result[:country]).to eq('India')
      expect(result[:minimum_salary]).to eq(1000.0)
      expect(result[:maximum_salary]).to eq(3000.0)
      expect(result[:average_salary]).to eq(2000.0)
    end

    it 'handles case-insensitive country matching' do
      result = Employee.salary_metrics_by_country('india')

      expect(result[:minimum_salary]).to eq(1000.0)
      expect(result[:maximum_salary]).to eq(3000.0)
    end

    it 'returns nil values when no employees found for a country' do
      result = Employee.salary_metrics_by_country('Canada')

      expect(result[:country]).to eq('Canada')
      expect(result[:minimum_salary]).to be_nil
      expect(result[:maximum_salary]).to be_nil
      expect(result[:average_salary]).to be_nil
    end
  end

  describe '.salary_metrics_by_job_title' do
    before do
      create(:employee, job_title: 'Developer', salary: 1000)
      create(:employee, job_title: 'Developer', salary: 3000)
      create(:employee, job_title: 'Manager', salary: 5000)
    end

    it 'returns average salary for a job title' do
      result = Employee.salary_metrics_by_job_title('Developer')

      expect(result[:job_title]).to eq('Developer')
      expect(result[:average_salary]).to eq(2000.0)
    end

    it 'handles case-insensitive job title matching' do
      result = Employee.salary_metrics_by_job_title('developer')

      expect(result[:average_salary]).to eq(2000.0)
    end

    it 'returns nil when no employees found for a job title' do
      result = Employee.salary_metrics_by_job_title('CEO')

      expect(result[:job_title]).to eq('CEO')
      expect(result[:average_salary]).to be_nil
    end
  end
end