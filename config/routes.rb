# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


#Ther is a problem with beautyfull urls. Maybe solve it later. 

#post 'schedules/:project_id' =>  "schedules#index"
#post 'schedules/edit_report' =>  "schedules#edit"



#display month
#get 'schedules/:project_id/:year/:month' => "schedules#index"
#create schedule
#post 'schedules/:project_id/:year/:month/:day/add_lucky' => "schedules#create"
#add report
#put 'schedules/:project_id/:year/:month/:day/update_report' => "schedules#update"
#edit report
#get 'schedules/:project_id/:year/:month/:day/edit_report' => "schedules#edit"
#delete schedules day
#post 'schedules/:project_id/:year/:month/:day/delete_duty_day' => "schedules#destroy"

#post 'schedules', to: "schedules#create"

#get 'schedules/(:id)' => "schedules#show", as: :show
match 'schedules/report' => "schedules#report", as: :complex_report, via: [:get,:post]
resources :schedules
resources :dutyreports

