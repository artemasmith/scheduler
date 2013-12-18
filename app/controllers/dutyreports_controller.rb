class DutyreportsController < ApplicationController
  unloadable
  before_filter :find_project , :find_schedule

  def edit
    @report = Dutyreport.find_by_id(params[:report_id])
  end

  def new
    @report = @sday.dutyreport.new()
  end

  def update
    p = params[:dutyreport]
    calltime = Time.new(p["call_time(1i)"],p["call_time(2i)"],p["call_time(3i)"],p["call_time(4i)"],p["call_time(5i)"])
    handletime = Time.new(p["handle_time(1i)"],p["handle_time(2i)"],p["handle_time(3i)"],p["handle_time(4i)"],p["handle_time(5i)"])
    @sday = Schedule.find_by_id(p[:id]) 
    p[:action] = :admin_change_duty
    
    if Schedule.may_do(p) || session[:user_id].to_i == @sday.user.id
      res = Dutyreport.find_by_id(params[:id]).update_attributes(client: p[:client], problem: p[:problem], day_id: p[:id],call_time: calltime, handle_time: handletime, report: p[:report])
    else
      flash[:error] = "Not enough permisiions"
    end
    flash[:notice] = "Successfully update" if res === true
        
    respond_to do |format|
      format.html { redirect_to schedules_path(project_id: @project, month: @sday.month, year: @sday.year) }
    end
  end

  def index
  end

  def destroy
    params[:action] = :delete_duty
    @sday ||= Schedule.find_by_id(params[:sday])
    if (Schedule.may_do(params) && session[:user_id].to_i == @sday.user.id) || Schedule.may_do({ action: :admin_change_duty, user: session[:user_id], project_id: params[:project_id] })
      @sday.dutyreport.find_by_id(params[:id]).destroy 
    else
      flash[:error]=  'Not enough rights'    
    end
    respond_to do |format|
      format.html { redirect_to schedule_path(id: @sday.id,project_id: @project, month: @sday.month, year: @sday.year) }
    end
  end

  def create
    p = params[:dutyreport]
    calltime = Time.new(p["call_time(1i)"],p["call_time(2i)"],p["call_time(3i)"],p["call_time(4i)"],p["call_time(5i)"])
    handletime = Time.new(p["handle_time(1i)"],p["handle_time(2i)"],p["handle_time(3i)"],p["handle_time(4i)"],p["handle_time(5i)"])
    p[:action] = :admin_change_duty
    if Schedule.may_do(p) or session[:user_id].to_i==@sday.user.id
      @sday.dutyreport.create(client: p[:client],problem: p[:problem], day_id: p[:id],call_time: calltime, handle_time: handletime, report: p[:report]) 
    else
      flash[:error] = "Not enough permisiions"
    end    
    respond_to do |format|
      format.html {redirect_to schedules_path(project_id: @project, month: @sday.month, year: @sday.year)}
    end
  end
  
  private
  
  def find_project
    pid = params[:project_id]
    pid ||= params[:dutyreport][:project_id]
    @project = Project.find_by_identifier(pid)    
  end
  
  def find_schedule
    id = params[:id]
    id ||= params[:dutyreport][:id]
    @sday = Schedule.find_by_id(id)
  end
  
  def may_change
    pid = params[:project_id]
    pid ||= params[:dutyreport][:project_id]
    p = { user: session[:user_id], project_id: pid, action: :change_duty }
    perm = Schedule.may_do(p)
    perm
  end
end
