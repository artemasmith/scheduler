class Dutyreport < ActiveRecord::Base
  unloadable
  
  belongs_to :schedule, dependent: :destroy
  validates :report, length: {maximum: 255}
  validates :problem, length: {maximum: 255}
  validates :client, length: {maximum: 100}
end
