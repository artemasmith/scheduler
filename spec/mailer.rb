require "spec_helper"

describe Dutymailer do

    before(:all)  do
	User.find(1).schedule.create(year: Date.tomorrow.year, month: Date.tomorrow.month, day: Date.tomorrow.mday, dpeople_id: 4, project_id: 'test')
	Dutymailer.send_notification(notify)    
    end
    let :notify do
	Schedule.get_notify_users()
    end
    
    it 'success send mail' do
	ActionMailer::Base.deliveries.last.to.should be (User.find(4).mail)
    end    
end
