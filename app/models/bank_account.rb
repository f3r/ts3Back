class BankAccount < ActiveRecord::Base
  using_access_control
  belongs_to :user
  # belongs_to :city
  validates_presence_of [:holder_street,:holder_zip, :holder_city_name, :holder_country_code], :message => "101"
  validate :validate_country

  private

  def validate_country
    local = ["SG"]
    if local.include?(self.holder_country_code)
      # clear unwanted fields
      self.iban = nil
      self.swift = nil
      errors.add(:account_number, "101") if self.account_number.blank?
      errors.add(:bank_code, "101") if self.bank_code.blank?
      errors.add(:branch_code, "101") if self.branch_code.blank?
    elsif !local.include?(self.holder_country_code)
      # clear unwanted fields
      self.account_number = nil
      self.bank_code = nil
      self.branch_code = nil
      errors.add(:iban, "101") if self.iban.blank?
      errors.add(:swift, "101") if self.swift.blank?
    end
  end

end