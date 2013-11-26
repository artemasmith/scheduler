require '/opt/redmine/spec/spec_helper'

describe Schedule do
    describe "check fields" do
	it {should respond_to(:dpeople_id)}
	it {should respond_to(:day)}
	it {should respond_to(:month)}
	it {should respond_to(:year)}
	it {should respond_to(:report)}
	it {should respond_to(:project_id)}
	
    end
    let (:day){return {day: 1,month: 1, year: 2012, dpeople_id: 4,  user: 1, project_id: 'test'}}
    let (:day2) {return {day: 2,month: 2, year: 2012, dpeople_id: 4,  user: 1, project_id: 'test'}}
#    let(:user){Dpeople.find_by_user_id(17)}
    let (:user) {User.where(id: 1)[0]}
#    before(:all){Dpeople.create(user_id: 17) if !Dpeople.find_by_user_id(17)}

#user with id=1 have all permissions
    
    describe "on wrong values insert" do
	let (:wrong_day){return {day: 32,month: 13, year: 2012, dpeople_id: 17, action: :change_duty, user: 1, project_id: 'test'}}
	
	before {Schedule.create(wrong_day)}
	it {should_not be_valid}
    end
    
    describe "normal duty creation" do	
	it "shoud be ok" do    
    	    expect{Schedule.create(day)}.to change{Schedule.count}.by(1)
        end
	describe "create with association" do
    	    before do 
    		Schedule.create(day)
    		Schedule.create(day2)
    	    end
        it {user.schedule.count.should == 2}
	end
    
	describe "build user's schedule" do
	    before {user.schedule.build(day)}
	    it {should be_valid}
	end
    end
    
    describe "schedule may have more than 1 report" do
	let (:report) {return {call_time: Time.now, handle_time: Time.now + 60,problem: "1", client: "1", report: "1" }}
	let (:report2) {return {call_time: Time.now + 100, handle_time: Time.now + 200,problem: "1", client: "1", report: "1" }}
	let (:sday) {Schedule.create(day)}
	
	describe "try to build" do
	    before {sday.build(report)}
	    it {should be_valid}
	end
	
	before do
	    sday.dutyreport.create(report)
	    sday.dutyreport.create(report2)
	end
	
	it {sday.dutyreport.count.should == 2}
	
    end
    
    

end