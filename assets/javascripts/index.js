//ADD-HANDLER FUNCTIONS

function add_onmouseover_handler(selector,func){
    var items=$("."+selector);
    for (i=0; i<items.length; i++){
	items[i].onmouseover = function(e){func(e);}
    }
}

function add_onclick_handler(selector,func){
    var items=$("#"+selector);
    for (i=0; i<items.length; i++){
	items[i].onclick = function(e){func(e);}
    }
}
//END ADD-HANDLER FUNCTIONS


//WORKING FUNCTIONAL
var display_index_report = function(e){
	if (e.target.localName=="td")
	{
	    var current=e.target.textContent.trim().split(" ")[0];
	    var reports=$(".hid, .report");
	    for (i=0; i<reports.length; i++)
	    {	
		reports[i].className= (reports[i].id==current && reports[i].textContent.trim()) ? 'report' : 'hid'; 
	    }
	}
}

var display_compex_report = function(e) {
    var all = $("div.hid, div.complex-report");
    for (i=0; i<all.length; i++){
	all[i].className = (all[i].id == e.target.textContent) ? 'complex-report highlight' : 'hid';
    }
}

var mark_if_report = function(e) {
    //unhighlight others
    var rdays=$('.rday');
    for (i=0; i<rdays.length; i++){
	rdays[i].className='rday';
    }
    
    //check if date has report, if yes - paint it
    var all = $("div.hid, complex-reportt, .highlight");
    for (i=0; i<all.length; i++){
	if (all[i].id==e.target.textContent.trim() && all[i].textContent.trim()){
	    e.target.className='rday highlight';
	}
	//e.target.className = (all[i].id == e.target.textContent.trim()) ? 'rday highlight' : 'rday';
	//var color = (all[i].id == e.target.textContent.trim()) ? 'orange' : 'blue';
	//$(this).css('color',color);
    }
}
function paint_if_taken() {
    var duties = $(".saturday");
    for (i=0; i<duties.length; i++)
    {
	if (duties[i].textContent.split(" ")[1].trim())
	{
	    duties[i].className='taken';
	}
    }
    
}
// END WORKING FUNCTIONAL

// ON PAGE LOAD
add_onmouseover_handler('saturday',display_index_report);
add_onmouseover_handler('rday',mark_if_report);
//add_onclick_handler("cell",display_compex_report);

paint_if_taken();
