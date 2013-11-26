require 'net/http'

class Api
    attr_accesor :url
    attr_accesor :uri
    
    def initialize
	@url="http://10.81.1.45/redmine/schedule"
	@uri=URI.parse @url
    end
    
    def create(year,month,day,user,report="")
	#check variables before adding to DB
	if (year<1900 and year>2200) or (month <0 and month >12) or (day <1 and day >31)
	    return "error"
	end
	xml_req=
	"<?xml version='1.0' encoding='UTF-8'?>
	<schedule>
	    <dyear type='integer'>#{year} </dyear>
	    <dmonth type='integer'>#{month} </dmonth>
	    <dday type='integer'>#{day} </dday>
	    <lucky type='integer'> #{user}</lucky>
	    <report type='string'>#{report} </report>
	</schedule>"
	
	request= Net::HTTP.new(@uri.host, @uri.port)
	response=http.request(request)
	
	responce.body
	
    end
    
    def read(id=nil)
	request=Net::HTTP.new(@uri.host, @uri.port)
	if id.blank?
	    response=request.get("#{@uri.path}.xml")
	else
	    response=request.get("#{@uri.path}/#{id}.xml")	    
	end
	response.body
    end
    
    
end