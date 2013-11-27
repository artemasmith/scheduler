Redmine::Plugin.register :scheduler do
  name 'Scheduler plugin'
  author 'Artem Kuznetsov'
  description 'This is a scheduler plugin for Redmine. It is needed for scheduling daily duty among staff'
  version '0.1.9.2'
  url 'http://github.com/artemasmith/scheduler'
  author_url 'http://www.github.com/artemasmith'
  
  project_module :schedule do
    permission :create_duty, :schedules => [:create,  :new]
    permission :change_duty, :schedules => [:create, :delete, :new, :destroy, :edit]
    permission :admin_change_duty, :schedules => [:update, :edit]
    permission :view_duty, :schedules => [:index, :show,  :report]
    permission :delete_duty, :schedules => [:destroy]
  end
 menu :project_menu, :schedule, {:controller => 'schedules', :action => 'index'}, :caption=> :schedule,:last=>true, :param => :project_id

 settings :default => {'duty' => ['6'],'period' => '52', 'vacation' => ' '}, :partial => 'settings/scheduler_settings'
end

module UserPatch
    def self.included(base)
	base.class_eval do
	    has_many :schedule, foreign_key: :dpeople_id
	end
    end
end

User.send(:include, UserPatch)