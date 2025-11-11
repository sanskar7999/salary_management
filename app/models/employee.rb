class Employee < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :job_title, presence: true
  validates :country, presence: true
  validates :salary, numericality: { greater_than: 0 }

  def full_name
    "#{first_name} #{last_name}"
  end
end
