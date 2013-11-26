require '/opt/redmine/spec/spec_helper'

describe "Scheduler" do

  describe "index" do

    it "should have the content " do
      visit 'redmine/schedules?project_id="test"'
      page.should have_content('Duty schedule')
    end
  end
end

describe Dutymailer do
#    let :sch {Schedule.new(year: Date.tomorow.year, month: Date.tomorow.month, day: Date.tomorow.mday, project_id: 'test', dpeople_id: 1)}
    before(:all) do
	Schedule.create(year: Date.tomorow.year, month: Date.tomorow.month, day: Date.tomorow.mday, project_id: 'test', dpeople_id: 1)
    end
    let :users {Dutymailer.get_users}
    
    it 'should have at least 1 user notification' do
	users.coutn.should be > 0
    end
    
    it 'should have an notification to admin1' do
	users.keys.should include(1)
    end
    
end
