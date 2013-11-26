require 'spec_helper'

describe Schedule do
    
    describe 'basic check' do
	it {should respond_to :get_notify_users}
    end
    


    describe 'mail neede section' do
	let :sch do
    	    Schedule.new(year: Date.tomorrow.year, month: Date.tomorrow.month, day: Date.tomorrow.mday, dpeople_id: 1, project_id: 'test')
	end
	before {sch.save}
	let :user do
    	    Schedule.get_notify_users()
	end
	it {user.should_not be 0}
	it 'should have inserted record' do
    	    user.keys.should include(1)
	end
    end


end
