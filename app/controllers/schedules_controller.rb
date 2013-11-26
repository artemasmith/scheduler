class SchedulesController < ApplicationController
  unloadable
  include SchedulesHelper

  before_filter :find_project, :authorize

  def index  
    params[:month]||=Date.today.month
    params[:year]||=Date.today.year
        
    @admin=Schedule.may_do(params.merge({user: session[:user_id], action: :admin_change_duty}))
    @week = render_week_days(Setting.plugin_scheduler)
    @period = make_year_period(params)
    @current_period=get_current_period
    @next_period= (@current_period >= @period.length - 1) ? false : @current_period + 1
    @duties=Schedule.get_period(params)
    @calendar=render_calendar(params)
    @pusers=Schedule.get_all_project_users(params[:project_id])
    
    @method=:post
    
    respond_to do |format|
	format.html
	format.pdf do 
	    render :pdf => 'index.pdf',
		    orientation: 'Landscape'
	end
    end
    
  end
  
  def show
    @sday=Schedule.find_by_id(params[:id])
    @day_reports=@sday.dutyreport
    respond_to do |format|
	format.html
	format.pdf do
	    render :pdf => 'show.pdf'
	end
    end
    
  end
  
  def report
    @period = make_year_period(params)
    @current_period=get_current_period
    @next_period= (@current_period >= @period.length - 1) ? false : @current_period + 1
    params[:page]||=1
    params[:from]||=Date.today.months_ago(1).month.to_s+" "+Date.today.months_ago(1).year.to_s
    params[:to]||=Date.today.month.to_i.to_s+" "+Date.today.year.to_s

    @reports=Schedule.get_period(params)
    
    flash[:error]=@reports if @reports.is_a? String
    @reports=@reports.paginate(page: params[:page], per_page: 10) if !@reports.is_a? String
        respond_to do |format|
	format.html
	format.pdf do 
	    render :pdf => 'reports.pdf',
		    orientation: 'Landscape'
	end
    end

  end


  def destroy
    result=Schedule.delete(params)
    if result
	flash[:error]=result
    else
	flash[:notice] = "Successfully decline date"
    end
    respond_to do |format|
        format.html {redirect_to schedules_path(params)}
        format.js
    end	
    
  end

  def update
    p=params[:schedule]
    @sday=Schedule.where('project_id = ? and year = ? and month = ? and day = ?',p[:project_id],p[:year],p[:month],p[:day])[0]
    res=''
    if !@sday.blank?
	res=Schedule.update(p)
    else
	res=Schedule.create(p)
    end
    
    if res
	flash[:error]=res 
    else
	flash[:notice]="Successfully updated"
    end    
    
    respond_to do |format|
	format.html {redirect_to schedules_path(:project_id=>params[:project_id],:year=>p[:year],:month=> p[:month])}
	format.js 
    end
  end

  def create
    @sparam={year: params[:year],month: params[:month],project_id: params[:project_id], day: params[:day], user: session[:user_id], dpeople_id: params[:dpeople_id]} if params[:schedule].blank?
    du=params[:dpeople_id]
    du||=session[:user_id]
    params[:wday]=Date.new(params[:year].to_i,params[:month].to_i,params[:day].split[0].to_i).wday
    @res=Schedule.create(@sparam)
    respond_to do |format|
	if @res.is_a? String
	    flash[:error]=@res
	    format.html {redirect_to schedules_path(:project_id=>params[:project_id],:year=>@sparam[:year],:month=> @sparam[:month])}
	    format.json {render json: @res}
	else	
	    flash[:notice]="Successfully create"
	    format.html {redirect_to schedules_path(:project_id=>params[:project_id],:year=>@sparam[:year],:month=> @sparam[:month])}
	    @sparam[:wday]=Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i).wday
	    @sday=Schedule.find_by_project_id_and_year_and_month_and_day(params[:project_id],params[:year],params[:month],params[:day])
	    @sparam[:day]="#{@sparam[:day]} #{User.find_by_id(du).name}"
	    format.js
	    format.json {render json:@sparam , status: :created}
	end
    end
  end
  

  private  

  def find_project
    id=params[:project_id]||=params[:schedule][:project_id]    
    @project=Project.find_by_identifier(id)
  end
end
