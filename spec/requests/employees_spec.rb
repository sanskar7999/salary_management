require 'rails_helper'

RSpec.describe "Employees API", type: :request do
  let(:valid_attributes) do
    {
      first_name: "John",
      last_name: "Doe",
      job_title: "Developer",
      country: "USA",
      salary: 60000
    }
  end

  let(:invalid_attributes) do
    {
      first_name: "",
      last_name: "",
      job_title: "",
      country: "",
      salary: -1
    }
  end

  describe 'GET /employees' do
    before { create_list(:employee, 3) }

    it 'returns all employees' do
      get employees_path, as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
    end
  end

  describe 'GET /employees/:id' do
    let(:employee) { create(:employee) }

    it 'returns the employee' do
      get employee_path(employee), as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(employee.id)
      expect(json['first_name']).to eq(employee.first_name)
    end
  end

  describe 'POST /employees' do
    context 'with valid params' do
      it 'creates a new Employee' do
        expect {
          post employees_path, params: { employee: valid_attributes }, as: :json
        }.to change(Employee, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['first_name']).to eq('John')
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable_content and errors' do
        post employees_path, params: { employee: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end
  end

  describe 'PUT /employees/:id' do
    let!(:employee) { create(:employee) }

    context 'with valid params' do
      it 'updates the employee' do
        put employee_path(employee), params: { employee: { job_title: 'Senior Developer' } }, as: :json
        expect(response).to have_http_status(:ok)
        expect(employee.reload.job_title).to eq('Senior Developer')
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable_content' do
        put employee_path(employee), params: { employee: { salary: -100 } }, as: :json
        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end
  end

  describe 'DELETE /employees/:id' do
    let!(:employee) { create(:employee) }

    it 'deletes the employee' do
      expect {
        delete employee_path(employee), as: :json
      }.to change(Employee, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'POST /employees/:id/deductions' do
    context 'India deductions' do
      let(:employee) { create(:employee, country: 'India') }

      it 'calculates TDS 10% and net salary' do
        post deductions_employee_path(employee), params: { gross_salary: 1000 }, as: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['tds']).to eq(100.0)
        expect(json['net_salary']).to eq(900.0)
      end
    end

    context 'US deductions' do
      let(:employee) { create(:employee, country: 'United States') }

      it 'calculates TDS 12% and net salary' do
        post deductions_employee_path(employee), params: { gross_salary: 1000 }, as: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['tds']).to eq(120.0)
        expect(json['net_salary']).to eq(880.0)
      end
    end

    context 'Other country no deductions' do
      let(:employee) { create(:employee, country: 'Canada') }

      it 'returns net = gross' do
        post deductions_employee_path(employee), params: { gross_salary: 500 }, as: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['tds']).to eq(0.0)
        expect(json['net_salary']).to eq(500.0)
      end
    end

    it 'returns bad_request when missing gross_salary' do
      employee = create(:employee)
      post deductions_employee_path(employee), as: :json
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'GET /employees/salary_metrics_by_country' do
    before do
      create(:employee, country: 'India', salary: 1000)
      create(:employee, country: 'India', salary: 2000)
      create(:employee, country: 'USA', salary: 3000)
    end

    it 'returns min, max and avg for a given country' do
      get salary_metrics_by_country_employees_path(format: :json), params: { country: 'India' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['minimum_salary']).to eq(1000.0)
      expect(json['maximum_salary']).to eq(2000.0)
      expect(json['average_salary']).to eq(1500.0)
    end
  end

  describe 'GET /employees/salary_metrics_by_job_title' do
    before do
      create(:employee, job_title: 'Developer', salary: 1000)
      create(:employee, job_title: 'Developer', salary: 3000)
      create(:employee, job_title: 'Manager', salary: 4000)
    end

    it 'returns average salary for a job title' do
      get average_salary_by_job_title_employees_path(format: :json), params: { job_title: 'Developer' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['average_salary']).to eq(2000.0)
    end
  end
end
