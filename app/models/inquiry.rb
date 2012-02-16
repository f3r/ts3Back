class Inquiry < ActiveRecord::Base
  belongs_to :user
  belongs_to :place
  
  serialize :extra
  
  def self.create_and_notify(place, user, check_in, check_out, params)
    extra = params.except("access_token", "controller", "action", "format")
    
    inquiry = self.create!(
      :place => place,
      :user => user,
      :check_in => check_in,
      :check_out => check_out,
      :extra => extra
    )
    
   InquiryMailer.inquiry_confirmed_renter(place, params).deliver
   InquiryMailer.inquiry_confirmed_owner(place, params, check_in, check_out, user).deliver
   InquiryMailer.inquiry_confirmed_admin(place, params, check_in, check_out, user, inquiry).deliver
  end
end
