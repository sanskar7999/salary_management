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
      it 'returns unprocessable_entity and errors' do
        post employees_path, params: { employee: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
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
      it 'returns unprocessable_entity' do
        put employee_path(employee), params: { employee: { salary: -100 } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
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
end
