class Schedule < ActiveRecord::Base
  unloadable
  
  belongs_to :user, foreign_key: :dpeople_id
  has_many :dutyreport, foreign_key: :day_id
  
  validates :dpeople_id, presence: true, numericality: true
  validates :project_id, presence: true, length: {maximum: 35}
  validates :day,presence: true, length: {maximum: 2}
  validates :month,presence: true, length: {maximum: 2}
  validates :year, presence: true, length: {maximum: 4}
  
###### NORMAL CODE


def self.get_all_project_users(id)
    res=[]
    users=Project.find(id).users
    if users
	users.each do |user|
	    res.append([user.lastname+ " " + user.firstname,user.id])
	end
    else
	return "db error"
    end
    return res
end



  #project - identifier of a project
  #returns minimum month and year of reports
  def self.find_edge_month(project,corner)
    if corner == :first
	year=Schedule.where(:project_id=>project).map{|s| s.year.to_i}.min
	month=Schedule.where(:year=>year, :project_id=>project).map{|s| s.month.to_i}.min
    else
	year=Schedule.where(:project_id=>project).map{|s| s.year.to_i}.max
	month=Schedule.where(:year=>year, :project_id=>project).map{|s| s.month.to_i}.max
    end
    return "#{year} #{month}" if year && month
    return nil
  end
  

    #check if given year month and day are good to parse in Date class variable
    #year,month,day - numbers of date in string (mostly)
    #return true when date is ok, and false if not
    def self.check_day(params)
	year=params[:year].to_i
	month=params[:month].to_i
	day=params[:day].to_i
	if year.to_i<1900 or year.to_i>2100 or month.to_i <1 or month.to_i >12 or day.to_i <1 or day.to_i>31
	    return false
	else
	    return true
	end
    end


  
  def date
    return "#{self.year} #{self.month} #{self.day}"
  end
  
  
  def self.get_period(params)    
    p1=p2=sy=sm=ey=em=''
    
    if (params[:from] && params[:to])
	sy=params[:from].split()[1].to_i
        sm=params[:from].split()[0].to_i
        ey=params[:to].split()[1].to_i
	em=params[:to].split()[0].to_i
	p1={year: sy, month: sm, day: 1}
	p2={year: ey, month: em, day: 1}	
    else
	sy=params[:year].to_i
        sm=params[:month].to_i	
	p1= {year: sy,month: sm,day: 1}
    	p2= false 
    	#params[:ey] && params[:em]) ? {year: params[:ey],month: params[:em],day: 1} : false    	
    end      
    result=[]
    return "start period error #{p1} #{params['from']}" if !Schedule.check_day(p1)
    if (p2) 
	return "end period error #{p2}" if  !Schedule.check_day(p2) 
    end    
    project_id=params[:project_id]
    schedules= (!p2) ? Schedule.where("project_id = ? and year = ? and month = ?",project_id,sy,sm) : Schedule.where(year: sy..ey, month: sm..em, project_id: project_id).order('year DESC, month DESC, day DESC')
    #.paginate(page: params[:page]).order('day DESC')  
    return schedules
  end
  
 #year=params[:year]	month=params[:month]	day=params[:day]	lucky=params[:lucky]	project_id=params[:project_id]	params[:user]
  def self.create(params)
    params[:action]=:create_duty
    return "no permissions" if !Schedule.may_do(params)
    return "incorrect date" if !Schedule.check_day(params)
    dpid=params[:dpeople_id]||=params[:user]
#    dp=Dpeople.find_by_user_id(dpid)
#    dp||=Dpeople.create(user_id: dpid)
    dp=User.find_by_id(dpid)
    sd=dp.schedule.build(project_id: params[:project_id],day: params[:day],month: params[:month], year: params[:year])
    return (sd.save) ? false : "error in db #{sd.errors}"
  end
  
  def self.update(params)
    params[:action]=:change_duty
    return "no permissions" if !Schedule.may_do(params)
    return "incorrect date" if !Schedule.check_day(params)
    s=Schedule.where('project_id= ? and year= ? and month= ? and day= ?',params[:project_id],params[:year], params[:month], params[:day])[0]
    dpid=params[:dpeople_id]||=params[:user]
#    dp=Dpeople.find_by_user_id(dpid)
#    dp||=Dpeople.create(user_id:dpid)
    dp=User.find_by_id(dpid)
    if !s.blank?
	return (s.update_attributes(dpeople_id: dp.id)) ? false : "error due db writing #{s.errors}"
	
    else
	return "error: #{s.errors}"
    end
  end

#params{:year,:month,:day,:project_id,:user}
  def self.delete(params)
#    return "wrong date" if !Schedule.check_day(params)
    return "wrong date" if !Schedule.check_day({year: params["year"],month: params["month"], day: params["day"]})
    puts "date is ok"
    params[:action]=:delete_duty
    return "not enough permissions" if !Schedule.may_do(params) 
    puts "we can delete"
    s=Schedule.where('day= ? and month = ? and year= ? and project_id= ?',params[:day],params[:month],params[:year],params[:project_id])[0]
    puts "schedule = #{s}"
    if s.destroy	
        return false
    else
        return "strange error #{s.errors}"
    end
  end

#params={action: :change_duty,user: 1,project_id: 'bug-tracking'}  
  def self.may_do(params)
    user = params[:user] || params[:dpeople_id]
    roles=User.find(user).roles_for_project(Project.find(params[:project_id]))
    for r in roles
	if r[:permissions].include?(params[:action])
	    return true 
	end
    end
    return false
  end
  
  def self.taken(day)
    lucky=Schedule.where("project_id = ? and year= ? and month= ? and day = ?",day[:project_id],day[:year],day[:month],day[:day])[0]
    return lucky.user if lucky
    return false
  end
  
# private
#    def check_permission
#	self.dpeople.user.
#    end
  


  
end
