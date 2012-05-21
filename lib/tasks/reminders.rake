namespace :reminders do
  desc "Send email reminders"
  task :unresponded_inquiries => :environment do
    inquiries = Inquiry.without_reply(3.days.ago)
    inquiries.each do |i|
      if i.created_at < 1.day.ago
        Rails.logger.info "Sending email reminder to #{i.recipient.email}"
        i.send_reminder
      end
    end
  end
end