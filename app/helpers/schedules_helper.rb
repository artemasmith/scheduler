module SchedulesHelper

## NORMAL CODE


#take '7 2013'
#returns 'July 2013'
def render_month(date)
    res= t(render_month_by_id(date.split()[0]).to_s) + " " + date.split()[1]
end

#gets 'prev|next',2013,7,'bug-tracking'
#return link_to 'Next month', :project_id=>project,:year=> ...
def render_navigation_link(duration,year,month,project)
  res = ''
  if Schedule.check_day(year: year, month: month, day: 1)
    if duration == "next"
      d = Date.new(year.to_i, month.to_i, 1).next_month
      res = link_to t('next_month'), schedules_path(:project_id => project, :year => d.year, :month => d.month), :class => 'navlink'
    else
      d = Date.new(year.to_i, month.to_i, 1).prev_month
      res = link_to t('previous_month'), schedules_path(:project_id => project, :year=> d.year, :month => d.month), :class => 'navlink'
    end
    return res
  end
end

def render_class(params)
  if duty_day?(params[:wday]) && !params[:day].blank?
    if params[:day].to_s.split[1]
      return 'taken'
    else
      return 'saturday'
    end
  else
    i = get_current_period
    return '' if params[:day].blank?
    day = { year: params[:year],month: params[:month], day: params[:day].to_s.split[0], i: i }
    return 'currentperiod' if in_period?(day)
    day[:i] += 1 if day[:i] < @period.length-1
    return 'nextperiod' if in_period?(day)
    return 'otherperiod'
  end
end

def render_yday(day)
  d = Date.ordinal(day[:year].to_i,day[:yday].to_i).to_s
  d = d.split("-")
  result = d[2]+" "+t(render_month_by_id(d[1]))+ " " + d[0]
  result
end

#{month str,year str,project str,duties{}}
def render_calendar(params)
  start = Date.new(params[:year].to_i, params[:month].to_i, 1)
  need_begin = !start.monday?
  calendar = []
  temp = {}
  end_of_month=start.end_of_month
  while start <= end_of_month	
    lucky = nil
    @duties.each { |d| lucky ||= d.user if start.mday == d.day.to_i } if !@duties.blank?
    temp[start.wday] = (lucky) ? "#{start.mday} #{lucky.name}" : start.mday
    if start.wday == 0
      calendar.append(temp)
      temp={}
    end
    start += 1
	
  end
  calendar.append(temp)
  if need_begin
    7.times do |i|
      calendar[0] = { i => " " }.merge(calendar[0]) if !calendar[0].include?(i)
    end
  end
  return calendar    
end

def day_taken(params)
  params[:day] = params[:day].to_s.split()[0]
  return Schedule.taken(params)
end
#wday -week day, check settings
def duty_day?(wday)
  return Setting.plugin_scheduler['duty'].include?(wday.to_s)
end
#day="2013-05"
def next_month(day)
  d = Date.parse(day+"-01")
  d = d.next_month
  return d.to_s.split("-")[0..1].join('-')
end

#day = {:year, :month}
def month_vacation(day)
  return 0 if Setting.plugin_scheduler['vacation'].blank?
  count = Setting.plugin_scheduler['period'].to_i * 7 / 30
  result = 0
  td = Date.new(day[:year].to_i,day[:month].to_i,1).to_s
  td = td.split("-")[0..1].join('-')
  count.times do |i|
    result += Setting.plugin_scheduler['vacation'].scan(/#{td}/).length if day[:month].to_i + i < 13
    td = next_month(td)
  end
  return result
end
#period={year,yday, period}
def get_period_vacation(period)
  result = 0
  d = Date.ordinal(period[:year].to_i, period[:yday].to_i)
  count = period[:period].to_i * 7 / 30
  count.times do
    result += month_vacation({year: period[:year], month: d.month})
    d = d.next_month
  end
  result
end

#day={:year,:month}
def make_year_period(day)
  year = []
  i = 1
  return [[1, 365]] if Setting.plugin_scheduler['period'].blank?
  while i < 365 do
    temp = [i]
    i += (Setting.plugin_scheduler['period'].to_i + get_period_vacation({year: day[:year], yday: i, period: Setting.plugin_scheduler['period'].to_i }))*7
    i = 365 if i > 365
    temp << i
    year << temp
    temp = []
    i += 1
  end
  year
end

#check if day is in period
#@period - array of year days [[1-36],[37-100],..]
#takes day ={year: ,month:, day:, i:} i-index of checked period in @period
#day={:year,:month,:day, i - index of @period}
def in_period?(day)
  date = Date.new(day[:year].to_i, day[:month].to_i, day[:day].to_i).yday
  (date >= @period[day[:i].to_i][0].to_i && date <= @period[day[:i].to_i][1]) ? true : false
end

#return index of current period in @period
def get_current_period()
  j = 0
  0..@period.length.times do |i|
    if Date.today.yday <= @period[i][1]
      j = i
      break
    end
  end
  j
end

#day = {year, month, day}
#return bool
def vac_day?(day)
  return false if day[:day].blank?
  cday=Date.new(day[:year].to_i, day[:month].to_i, day[:day].to_i).to_s
  if !Setting.plugin_scheduler['vacation'].blank?
    return true if Setting.plugin_scheduler['vacation'].match("#{cday}")
  else
    return false
  end
  false
end

#duty_days - from settings wich days are duty
def render_week_days(duty_days)
  start = Date.today.beginning_of_week
  week = {}
  end_of_week = start.end_of_week
  while start <= end_of_week
    cls = (duty_days.include?(start.wday.to_s) ? "duty" : "cal")
    day = wday_to_str(start.wday) 
    week[day] = cls
    start += 1
  end
  week
end

#params {:user, :project_id, :action=:admin_change_duty}
def is_admin(params)
  Schedule.may_do(params)
end

def render_month_by_id(id)
  case id.to_i 
  when 1
    return 'january'
  when 2
    return 'february'
  when 3
    return 'march'
  when 4
    return 'april'
  when 5
    return 'may'
  when 6
    return 'june'
  when 7
    return 'july'
  when 8
    return 'august'
  when 9
    return 'september'
  when 10
    return 'october'
  when 11
    return 'november'
  when 12
    return 'december'
  end
end

def wday_to_str(day)
  case day
  when 1
    'monday'
  when 2
    'tuesday'
  when 3
    'wensday'
  when 4
    'thuesday'
  when 5
    'friday'
  when 6
    'saturday'
  when 0
    'sunday'
  end
end

#get standart params and return array of links to display by ajax script
def get_month_links(params)
  today = Date.new(params[:year].to_i,params[:month].to_i,1)
  enday = today.end_of_month
  tparams = params
  tparams[:day] = 1
  result = {}
  while today <= enday
    if duty_day?(today.wday)
      result[today.mday] = render_day_link(tparams)
    end    
    today += 1
    tparams[:day] = today.mday
    tparams[:wday] = today.wday
  end
  result
end


def render_day_link(params)
  if !params[:day].blank? and duty_day?(params[:wday])
    day = params[:day].to_s.split()[0].to_i	
    d = Date.new(params[:year].to_i,params[:month].to_i,day)
    sday = Schedule.where(project_id: params[:project_id],year: params[:year], month: params[:month],day: day)[0]
    if sday
      path = "#"
      link = params[:day]
      if  sday.dutyreport.count > 0
  	path = schedule_path(id: sday.id, project_id: params[:project_id], year: params[:year], month: params[:month], day: day)
	link = link_to "#{params[:day]}", path
      end
      if d <= Date.today
	addlink = link_to t("create"),new_dutyreport_path(id: sday.id, project_id: params[:project_id], year: params[:year], month: params[:month], day: day), class: 'btn'
	result = " <span class=\"row span12\">  #{link} </span>  <span class=\"row\"> #{addlink} </span>".html_safe
      else 
	return params[:day]
      end
      return result
    end
  end
  return params[:day]
end

def render_select_period(project)
  first = Schedule.find_edge_month(project,:first)
  last = Schedule.find_edge_month(project,:last)
  first ||= Date.today.year.to_s + " " + Date.today.month.to_s
  last ||= Date.today.year.to_s + " " + Date.today.month.to_s
  sm = first.split()[1]
  sy = first.split()[0]
  em = last.split()[1]
  ey = last.split()[0]
  start = Date.new(sy.to_i, sm.to_i, 1)
  till = Date.new(ey.to_i, em.to_i, 1)
  period = []
  while start <= till
    period.append([render_month(start.month.to_s + " " + start.year.to_s), start.month.to_s + " " + start.year.to_s])
    start=start.next_month
  end
  period    
end

def paint_cg(day)
  colors = ['success', 'error', 'warning', 'info']
  id = day.id
  res = colors[day.id % 4]
end


end
