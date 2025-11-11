class Employee < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :job_title, presence: true
  validates :country, presence: true
  validates :salary, presence: true, numericality: { greater_than: 0 }

  # Scopes for querying by country and job title (case-insensitive)
  scope :by_country, ->(country_name) { where("lower(country) = ?", country_name.to_s.downcase) }
  scope :by_job_title, ->(job_title_name) { where("lower(job_title) = ?", job_title_name.to_s.downcase) }

  def full_name
    "#{first_name} #{last_name}"
  end

  # Instance method: Calculate TDS and net salary for a given gross salary
  def calculate_deductions(gross_salary)
    gross = gross_salary.to_f
    tds_rate = tds_rate_for_country
    tds = (gross * tds_rate).round(2)
    net = (gross - tds).round(2)

    {
      employee_id: id,
      country: country,
      gross_salary: gross,
      tds: tds,
      net_salary: net
    }
  end

  # Determine TDS rate based on employee's country
  def tds_rate_for_country
    case country.to_s.strip.downcase
    when "india" then 0.10
    when "united states", "usa", "us" then 0.12
    else 0.0
    end
  end

  # Class method: Get salary metrics for a given country
  def self.salary_metrics_by_country(country_name)
    employees = by_country(country_name)

    {
      country: country_name,
      minimum_salary: employees.minimum(:salary)&.to_f,
      maximum_salary: employees.maximum(:salary)&.to_f,
      average_salary: employees.average(:salary)&.to_f
    }
  end

  # Class method: Get average salary for a given job title
  def self.average_salary_by_job_title(job_title_name)
    employees = by_job_title(job_title_name)

    {
      job_title: job_title_name,
      average_salary: employees.average(:salary)&.to_f
    }
  end
end
