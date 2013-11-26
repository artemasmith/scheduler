class Period < ActiveRecord::Base
  unloadable
#  include 'Schedule'

  #days={day1,month1,year1, day2,month2,year2,project_id}
  @this_year
  def self.create(days)
    return false  if !Schedule.check_day({day: days[:day1], month: days[:month1], year: days[:year1]})
    return false if !Schedule.check_day({day: days[:day2], month: days[:month2], year: days[:year2]})
    d1=Date.new(days[:year1].to_i,days[:month1].to_i,days[:day1].to_i)
    d2=Date.new(days[:year2].to_i,days[:month2].to_i,days[:day2].to_i)
    p=Period.new(start: day1, stop: day2, project_id: days[:project_id])
    if p.save 
	return true
    else
	return false
    end
  end
  
  def get_year_period(params)
    
  end
end
