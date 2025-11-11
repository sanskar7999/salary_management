class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[show update destroy deductions]

  # GET /employees
  def index
    @employees = Employee.all
    render json: @employees
  end

  # GET /employees/:id
  def show
    render json: @employee
  end

  # POST /employees
  def create
    @employee = Employee.new(employee_params)

    if @employee.save
      render json: @employee, status: :created
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /employees/:id
  def update
    if @employee.update(employee_params)
      render json: @employee
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /employees/:id
  def destroy
    @employee.destroy
    head :no_content
  end

  # GET /employees/salary_metrics_by_country?country=India
  def salary_metrics_by_country
    country = params[:country]
    return render json: { error: 'country is required' }, status: :bad_request if country.blank?

    scope = Employee.where('lower(country) = ?', country.to_s.downcase)
    min = scope.minimum(:salary)
    max = scope.maximum(:salary)
    avg = scope.average(:salary)

    render json: {
      country: country,
      minimum_salary: min&.to_f,
      maximum_salary: max&.to_f,
      average_salary: avg&.to_f
    }
  end

  # GET /employees/salary_metrics_by_job_title?job_title=Developer
  def salary_metrics_by_job_title
    job_title = params[:job_title]
    return render json: { error: 'job_title is required' }, status: :bad_request if job_title.blank?

    scope = Employee.where('lower(job_title) = ?', job_title.to_s.downcase)
    avg = scope.average(:salary)

    render json: {
      job_title: job_title,
      average_salary: avg&.to_f
    }
  end

  # POST /employees/:id/deductions
  def deductions
    gross = params[:gross_salary]
    return render json: { error: 'gross_salary is required' }, status: :bad_request if gross.nil?

    gross = gross.to_f

    tds_rate = case @employee.country.to_s.strip.downcase
               when 'india' then 0.10
               when 'united states', 'usa', 'us', 'unitedstates' then 0.12
               else 0.0
               end

    tds = (gross * tds_rate).round(2)
    net = (gross - tds).round(2)

    render json: {
      employee_id: @employee.id,
      country: @employee.country,
      gross_salary: gross,
      tds: tds,
      net_salary: net
    }
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Employee not found" }, status: :not_found
  end

  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :job_title, :country, :salary)
  end
end

