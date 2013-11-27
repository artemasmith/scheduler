class DBgetter < ActiveRecord::Base
###
### Section for mail-notification
###

  require 'socket'

  #search users wich we need to notify about coming duty
  #return {user_id: [days before duty, link_to_schedule]}
  def self.get_notify_users(options)
    (!options[:dday].blank?) ? dday = options[:dday].to_i : dday = 3
    project_id = options[:project_id] ||= false
    nusers = options[:nusers] ||= false
    today = Date.today
    users = {}
    Schedule.last(20).each do |s|        
        next if project_id && project_id.include?(s.project_id.to_s)
        next if nusers && nusers.include?(s.dpeople_id.to_i)
        deltaday=(Date.new(s.year.to_i,s.month.to_i,s.day.to_i) - today).to_i
        if  deltaday > 0 and deltaday < dday
            users[s.dpeople_id]=[deltaday.to_s, 'https://' + Socket.gethostname + '/redmine/Schedules?project_id=' + s.project_id + '&month=' + s.month.to_s + '&year=' + s.year.to_s]
        end
    end
    return 0 if users.blank?
    return users
  end
  
  #array of projects in which to notify
  def self.get_managers(projects)
    managers =[]
    arProjects=[]
    (projects.blank?) ? arProjects = Project.all : projects.each {|p| arProject << Project.find_by_identifier(p)}
    arProjects.each do |p|
	p.members.each do |m|
	    m.roles.each {|r| managers << m.user.id if r.permissions.include?(:admin_change_duty)}
	end
    end
    managers
  end
  
  #projects - list of project_id separated by comma
  def self.get_empty_days(projects)
    empty = []
    arProjects=[]
    (projects.blank?) ? arProjects = Project.all : projects.each {|p| arProjects <<  Project.find_by_identifier(p)}
    
    wdays=Setting.plugin_scheduler['duty']
    arProjects.each do |p|
	today = Date.today
	endOfWeek = Date.today.end_of_week
        while today < endOfWeek
	    if wdays.include?(today.wday.to_s)
		s=Schedule.where(day: today.mday, month: today.month, year: today.year)
		empty.push([today, p.identifier]) if s.blank?
	    end
	    today+=1
	end
    end
    empty
  end
  
  def self.get_notification_managers(projects)
    managers = self.get_managers(projects)
    empty = self.get_empty_days(projects)
    return false if (managers.blank? || empty.blank?)
    result={}
    managers.each do |m|
	empty.each do |e|
	    result[m]=[e[0], 'https://' + Socket.gethostname + '/redmine/Schedules?project_id=' + e[1] + '&month=' + e[0].month.to_s + '&year=' + e[0].year.to_s]
	end
    end
    result
  end

end

require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require "mailer"
class Dutymailer < ActionMailer::Base
    default from: 'redmine@tmn.transneft.ru'
    include Redmine::I18n


  #params = {user_id: [days before duty, link_to_schedule]}
  def send_notification(users)
    users.each do |id,params|
        @user=User.find_by_id(id.to_i)
        lang=@user.language
        lang||=Setting.default_language
        set_language_if_valid(lang)
        @days=params[0]
        @link=params[1]
        mail(to: @user.mail, subject: t(:duty_day)).deliver
    end

  end
end




namespace :redmine do

desc "Send mail notifications to duty users. It takes parameters: environment, users(who do not neet to notify), projects(list of projects comma separated wich users will be notified, if empty - all), days - count of day before notification"
task notify_users: :environment do
    options = {}
    options[:dday] = ENV['days']
    options[:nusers] = ENV['users'].split(',').map{|u| u.to_i} if ENV['users']    
    options[:project_id] = ENV['projects'].split(',').map{|u| u.to_s} if ENV['projects']
    users = DBgetter.get_notify_users(options)
    if users == 0
    	puts 'there is nobody for notify'
    else
	puts "send notifications to #{users.keys}"
    	Dutymailer.send_notification(users)
    end
    
    #managers notification area
    managers = DBgetter.get_notification_managers(options[:project_id])
    if !managers.blank? 
	puts "send manager notification #{managers}"
	Dutymailer.send_notification(managers)
    else
	puts "no managers to notify #{managers}"
    end
    
end


end

