// js+protovis code from the old PH

var
    vis,
    context,
    focus,
    data_points,
    new_data,
    small_data,
    tiny_data,
    view,
    tutorial = false,
    synthetic = false,
    planet   = false,
    less_points = false,
    select_bar,
    select_active = false,
    dots,
    advanced_interface = false,
    y_errors,
    lightcurve_data,
    reduced_lg_data,
    zoom_anim_timer,
    rel_shift,
    guide,
    t,
    drag_x,
    drag_y,
    w               = 670,
    h               = 440,
    zoomed_width    = 670,
    zoomed_height   = 440,
    k               = 3,
    kx              = w / h,
    ky              = 1,
    x               = pv.Scale.linear(-2, 36).range(0, w),
    y               = pv.Scale.linear(1.007, 1.008).range(0, h),
    iR,
    fx,
    fy,
    x_interval      = x.domain()[1] - x.domain()[0],
    y_interval      = y.domain()[1] - y.domain()[0],
    zoom            = 1,
    zoom_in         = 0,
    zoom_out        = 0,
    w               = 670,
    h1              = 400,
    h2              = 30,
    marked_transits = [],
    cPan,
    period          = 9,
    scaled          = false;

$(document).ready(function(){
  $("a.more").live('click', function () {
    scaled=!scaled;
    $(this).toggleClass('more');
    $(this).toggleClass('less');
  });

  $("a.less").live('click', function () {
    scaled=!scaled;
    $(this).toggleClass('more');
    $(this).toggleClass('less');
  });
});


function toggle_actual_transits(){
for(var i=0; i < new_data.length; i++ ){
		data[i].show=!data[i].show;
	}
	data_points.data(data);
	vis.render();
}

function focus_transit (transit_id, zoom){
  var edit_container = $('.step .actions .edit');
  $('.transit').removeClass('focus');
  $('.transit .delete').fadeOut();


  $('.transit[title='+ transit_id+']')
  .addClass('focus')
  .find('.delete').fadeIn();


for(var i = 0; i< marked_transits.length; i++){
    if  (marked_transits[i].$properties[1].value[0].id==transit_id	){
      selected_id= i;
    }
  }



if(zoom){
	
	
	
	var x_pos = marked_transits[selected_id].$properties[1].value[0].x;
	var dx = marked_transits[selected_id].$properties[1].value[0].dx;

	var ixs = (x(x_pos));
	var ixe = (x(x_pos+Math.max(dx,2)));
	
	
	less_points=true;

	var lT      = Math.max(ixs - 2.0*(ixe-ixs), 0);
	var rT		= Math.min(ixe + 2.0*(ixe-ixs), 660) ;
	
	var lStep   = Math.abs(iR.x- lT)/20.0;
	var rStep  = Math.abs(iR.x+iR.dx -rT )/20.0;
    clearInterval(zoom_anim_timer);
	
	zoom_anim_timer= setInterval("zoom_amin("+lT+","+rT+","+lStep+","+rStep+")",10);
					
					// iR = {x:ixs-w*2, dx: w*4};
					// 				cPan.data([iR]);
					// 				vis.render();
}	
}



function anim_done(){
	less_points=false;
	vis.render();
}


function zoom_amin(targetL,targetR,stepL,stepR){

var xOld = iR.x ;
var dxOld = iR.dx;

if (Math.abs( (iR.x-targetL) )<stepL && Math.abs((iR.x+iR.dx)-targetR) < stepR){
	anim_done();
	clearInterval(zoom_anim_timer);
	console.log("done");
}
else{
	var startChange=0
	
	if ( Math.abs( (iR.x-targetL) )>stepL){
		if (iR.x>targetL){
			iR.x= iR.x-stepL;
		}
		else{
			iR.x= iR.x+stepL;
		}
	}
	
 	if(Math.abs( ( (iR.x+iR.dx)-targetR) )>stepR){
		if(  (iR.x+iR.dx) > targetR ){
			iR.dx= xOld - iR.x + dxOld -stepR; 
		}
		else{
			iR.dx= xOld - iR.x + dxOld +stepR ;
		}
	
	}

cPan.data([iR]);
cPan.render();
focus.render();
}

}


function remove_transit_box(id){
var selected_id;
for(var i = 0; i< marked_transits.length; i++){
  if  (marked_transits[i].$properties[1].value[0].id==id){
    selected_id= i;
  }
}
marked_transits[selected_id].data([]);
marked_transits.splice(selected_id,1);
vis.render();
}

function add_transit_box(x,y,dx,dy,auto){
var xDom    = fx.domain();
var yDom    = fy.domain();
var s_x,s_y, s_height,s_width;
var transit_no = marked_transits.length+1 ;
if (transit_no==null){
	transit_no=1;
}

if (auto){
	var width   =  Math.abs(xDom[xDom.length-1] -  xDom[0])/8.0;
    var height  =  Math.abs(yDom[yDom.length-1] -  yDom[0])/2.0;
	var xMid    = (xDom[xDom.length-1] +  xDom[0])/2.0 - 0.5 * width;
	var yMid    = (yDom[yDom.length-1] +  yDom[0])/2.0- 0.5*height;
	if(marked_transits.length==0){
	
		s_x = xMid;
		s_y = yMid;
		s_width = width;
		s_height= height;
	}
	else{
		s_x =xMid;
		s_y =yMid;
		s_width = marked_transits[marked_transits.length-1].$properties[1].value[0].dx;
		s_height= marked_transits[marked_transits.length-1].$properties[1].value[0].dy;
		
	}
}
else if(dx >10 && dy >10 && auto==false){
  s_width  = fx.invert(x+dx) - fx.invert(x);
  s_height = fy.invert(y+dy)-fy.invert(y);
  s_x      = fx.invert(x);
  s_y      = (yDom[yDom.length-1]- (fy.invert(y)- yDom[0]))-s_height;
}
else{
	select_bar.fillStyle("rgba(255, 128, 128, 0)");
  	focus.render();
	return null; 
}

  var transit_pan = focus.add(pv.Panel)
	.def("show_guide",function() 1)
    .data([{"x": s_x,"y": s_y , "dx": s_width ,"dy": s_height, "id":transit_no, "add_type":auto}])
      .overflow("hidden")
    .event("mousedown", pv.Behavior.scaled_drag(fx,fy))
    .event("click", function(d) focus_transit(d.id,false));
    //.event("child_resize", pv.Behavior.scaled_resize("bottom right",fx,fy));



  var transit = transit_pan.add(pv.Bar)
     .left(function(d) fx(d.x))
     .bottom(function(d) fy(d.y))
     .width(function(d) fx(d.x+d.dx)-fx(d.x))
     .height(function(d) fy(d.y+d.dy)-fy(d.y))
     .fillStyle(pv.rgb(150,150,150,.15))
     .strokeStyle("#09C")
     .lineWidth(4)
     .cursor("move");

//show guides 
 if(period!=null && advanced_interface){
	transit_pan.event("mouseover", function() {transit_pan.show_guide(1);$(".star_name").html("possible extra transits with period "+period).show().delay(3200).fadeOut(1600);transit_pan.render()})
	.event("mouseout", function() this.show_guide(-1))
 	
	for(var l=-5; l< 5; l++ ){
		if(l!=0){
	 		transit_pan.add(pv.Panel)
				.add(pv.Bar)
				.def("off",  period*(l) )
				.left(function(d) fx(d.x +this.off()))
				.bottom(function(d) fy(0))
				.width(function(d) fx(d.x+d.dx)-fx(d.x))
				.height(function(d) fy(10))
			    .fillStyle(function() transit_pan.show_guide()==1 ? "rgba(255, 128, 128, .1)" :"rgba(255, 128, 128, 0)" )
				.events("none");
				
			
			
		}
 	}
 }

  var drag_corner = transit_pan.add(pv.Bar)
    .left(function(d) fx(d.x+d.dx)-10)
    .bottom(function(d) fy(d.y))
    .width(10)
    .height(10)
    .cursor("se-resize")
    .fillStyle("#09C")
    .event("mousedown", pv.Behavior.scaled_resize("",fx,fy) )
    .event("resize", transit_pan);

  transit.anchor("left").add(pv.Dot)
    .size(100)
    .strokeStyle("#09C")
    .fillStyle("#FFF")
    .lineWidth(3)
  .anchor("center").add(pv.Label)
    .text(transit_no)
    .font("14px sans-serif");

  transit.anchor("center").add(pv.Dot)
       .size(4)
       .fillStyle("#09C");

  marked_transits.push(transit_pan);

  var  transit = $('<div/>', {'id': 'transit' + transit_no, 'class': 'transit active'});
  create_transit_button(transit_no);
  get_transit_coords();
	


select_bar.fillStyle("rgba(255, 128, 128, 0)");
focus.render();





return transit;
}

function	create_transit_button (transit_number){
var
    edit_container = $('.step .actions .edit');

var number = edit_container.find('.transit:first-child')
.clone()
.data('transit_id', 'transit' + transit_number)
.attr('title', transit_number)
.text(transit_number)
.css('display', 'inline-block')
.append($('<a/>', {'class': 'delete', 'href': '#', 'title': 'delete'}).click(
	function(evt){
evt.preventDefault();
		var number =$(this).parent().attr("title");
		remove_transit_box(number);
$('.transit.focus').fadeOut(function(){
  $(this).remove();
});
$(this).parent().fadeOut(function(){
  $(this).remove();
});
}));
edit_container.find('.add').before(number);
number.click(function()	{focus_transit(transit_number, true)});
}

function get_transit_coords(){


var transit_coords=[];
for(var i = 0 ; i<marked_transits.length; i++){
  var values = marked_transits[i].$properties[1].value[0];
  transit_coords.push(  {marker_id : values.id,
                             x : values.x,
                             y : values.y,
                             width : values.dx,
                             height: values.dy,
						   add_type: values.add_type
                          });
}
    return transit_coords;
}


function loading(){
  $("#graph").html('<%=image_tag "spinner.gif", :class=>"spinner"%>');

}

function loaded(){
  $(".graph .loading").hide();
}

function show_tooltips(){
$("#xZoom_help").show().delay(3200).fadeOut(1600);
$("#yZoom_help").show().delay(3200).fadeOut(1600);
}

function show_transit_tooltips(){
$("#drag_help").show().delay(3200).fadeOut(1600);
}





function addSelectBar(){
	select_bar =focus.add(pv.Panel)
		.data([{"x":0, "y":0, "dx":0 , "dy" :0}])
	    .cursor("crosshair")
	    .events("all")
	    .event("mousedown",pv.Behavior.select())
		.event("selectstart",function(d) select_bar.fillStyle("rgba(255, 128, 128, 0.4)"))
		.event("selectend", function(d) {add_transit_box(d.x,(d.y),d.dx,d.dy,false);} )
	  .add(pv.Bar)
	    .left(function(d) d.x)
	    .width(function(d) d.dx)
		.top(function(d) (d.y))
		.height(function(d) d.dy)
	    .fillStyle("rgba(255, 128, 128, .4)");
	  vis.render();
    
}

var load_graph = function(target_light_curve){
loading();

  vis = new pv.Panel()
    .canvas('graph')
    .width(w)
    .height(h)
    .top(5)
    .bottom(30)
    .left(50)
    .right(5);

marked_transits=[];

if("<%=lightcurve%>"=="tutorial_light_curve"){
	tutorial=true;
}
<%if @source_select%>
   <% lightcurve = "next_light_curve/?lightcurve_id=#{@source_select}" %>
<%end%>

if (typeof target_light_curve === 'undefined') {
	target_light_curve= "<%=lightcurve%>";
} 

  $.ajax({url: '/light_curves/'+target_light_curve,
  error: function(){
$(".spinner").remove();
  $(".workflow").html(" <div class='step step0' style='margin-top:100px;'><p class='question'><%=t('lightcurve.all_done')%></p></div>");
  $(".step0").show();
  $(".more_info").hide();
  $("#favorite_and_download").hide();
  },
  success: function(objJson){
  classification = {'light_curves': [objJson.light_curve.id], 'annotations': []};
    $(document).trigger('loading', {'lightcurve': objJson.light_curve});
  
  if(objJson.light_curve.source.kind=="simulation"){
	synthetic = true; 
  }
  else if(objJson.light_curve.source.kind=="planet"){
	planet = true;
  }
  priority=objJson.light_curve.priority;

  rel_shift= objJson.light_curve.rel_start_time ;

    setup_lightcurve_data_on_page(objJson.light_curve);
    load_light_curve_data(objJson.light_curve.light_curve_url);
  }
 });
};


function round_float(x,n){
  if(!parseInt(n))
    var n=0;
  if(!parseFloat(x))
    return false;
  return Math.round(x*Math.pow(10,n))/Math.pow(10,n);
}

function load_light_curve_data(light_curve_url){
if (tutorial){
	light_curve_url = "/tutorial_light_curve.json";
}
  $.jsonp({callback:"light_curve_data",
    url: light_curve_url,
    error: function(){ alert("<%=t('lightcurve.failed_to_get')%>"+ light_curve_url);},
    success: function(objJson){
    if (!objJson || objJson.length <= 0) { alert("<%=t('lightcurve.problem')%>");}

    data = objJson;

    if(data.meta_data){
    	data=data.data;
    }

  <%if @shift_time %>
  	for(var i = 0; i < data.length; i++){
		data[i].x=data[i].x + rel_shift;
	  }
  <%end%>

    var no_points = data.length;
    new_data=[];
  small_data=[];
  tiny_data=[];
    var ymax= 0;
    var ymin =1000000;

    for(var i=0; i<no_points; i++){

	if(data[i].y>0){
		var tr =  synthetic || tutorial ? Math.floor(data[i].tr) : 0 ;
		var y  =  synthetic || priority ? data[i].y*1.008 : data[i].y;
		var dy =  synthetic ? data[i].dy : data[i].dy;
		var data_with_transits= {"x": (data[i].x<1000 ? data[i].x : data[i].x-data[0].x) , "y": y, "dy":dy, "tr": tr, "show":false, "s":tr};
      if (i%3==0){
        	small_data.push(data_with_transits);
      }
	if(i%8==0){
		tiny_data.push(data_with_transits);
	}
      new_data.push(data_with_transits);
      if (data_with_transits.y >ymax) ymax=data_with_transits.y;
      if (data_with_transits.y <ymin) ymin=data_with_transits.y;

    }
  }

data=null;

<%if @transits%>
	$("#graph").after("<div id='color_bar'></div>");
	$("#color_bar").append("<ul style='width:725px; height:30px; list-style-type:none;;'>");
	for(var i=1; i<100; i+=2){
		$("#color_bar").append("<li style='width:20px; height:30px; float:left; background-color:hsl("+i*360.0/(100.0)+",50%,50%); font-size:10pt;list-style-type:none;'>"+i+"</li>");
	}
	$("#color_bar").append("</ul>");
	
	for(var i =0 ; i < new_data.length; i++){
		new_data[i].tr=0;
	}
	
	var transits = <%=@transits.to_json.html_safe%>;
	for(var i =0; i<transits.length; i++){
		var transit = transits[i];
		for(var j=0; j<new_data.length; j++){
			new_data[j].show=true;
			if (new_data[j].x> transit.x && new_data[j].x < transit.x+transit.width &&
			   new_data[j].y> transit.y && new_data[j].y < transit.y+transit.height){
				new_data[j].tr+=1.0/<%=@classification_count%>;
			}
		}
	}		
	


<%end%>


 
      data=new_data;
      no_points = data.length;



      var start = new_data[0].x;//- 0.05* (new_data[no_points-1].x - new_data[0].x );
      var end   = new_data[no_points-1].x ;//+ 0.05* (new_data[no_points-1].x - data[0].x );

var yrange= ymax-ymin;
ymax=ymax+0.15*yrange;
ymin=ymin-0.15*yrange;

  /* Scales and sizing. */
      x = pv.Scale.linear(start, end).range(0, w);
      y = pv.Scale.linear(ymin, ymax).range(0, h2);

  /* Interaction state. Focus scales will have domain set on-render. */
      iR  ={x:0, dx:660};
      fx = pv.Scale.linear().range(0, w);
      fy = pv.Scale.linear().range(0, h1);

  focus = vis.add(pv.Panel)
      .def("init", function() {
          var d1 = x.invert(iR.x),
              d2 = x.invert(iR.x + iR.dx),
			ld = (less_points ? tiny_data : new_data),
              dd = ld.slice(
                  Math.max(0, pv.search.index(ld, d1, function(d) d.x) - 1),
                  pv.search.index(ld, d2, function(d) d.x) + 1);
          fx.domain(d1, d2);

		if(scaled){
      		var max=  pv.deviation(dd,function(d) d.y)*3.0+ pv.mean(dd,function(d) d.y);
      		var min= pv.min(dd,function(d) d.y);
      		var width  = max-min;
			fy.domain ( [min-(0.15)*(max-min),max-0.05*(max-min)] );
		}
		else{
          	fy.domain(y.domain());
		}
      // fy.domain(y.domain());
          return dd;
        })
      .top(0)
      .height(h1);


	


    focus.add(pv.Rule)
        .data(function() fx.ticks())
        .left(fx)
        .strokeStyle(pv.rgb(68,68,68,1))
      .strokeDasharray("1,4")
      .anchor("bottom").add(pv.Label)
        .text(fx.tickFormat)
        .strokeStyle("#FFF")
      .textStyle(pv.rgb(97,97,97,1));



    /* Y-axis ticks. */
    focus.add(pv.Rule)
        .data(function() fy.ticks(7))
        .bottom(fy)
        .strokeStyle(pv.rgb(68,68,68,1))
      .strokeDasharray("1,4")
      .anchor("left").add(pv.Label)
        .text(fy.tickFormat)
      .left(-10)
      .font('10px Myriad Pro')
      .textStyle(pv.rgb(97,97,97,1));

    /* Focus area chart. */




    y_errors=focus.add(pv.Panel)
        // .overflow("hidden")
      .add(pv.Rule)
        .data(function() focus.init())
        .left(function(d) fx(d.x))
        .bottom(function(d) fy(d.y-d.dy))
        .height(function(d) fy(d.y+d.dy) - fy(d.y-d.dy))
        .lineWidth(1.00)
        .strokeStyle( pv.rgb(239, 239, 239, 0.1));


		  data_points = focus.add(pv.Dot)
            .data(function() focus.init())
		  .left(function(d) fx(d.x))
          .bottom(function(d) fy(d.y))
          .size(3)
          .fillStyle(function(d)   d.show && d.tr>0 ? "hsl("+d.tr*360.0+", 50%, 50%)" : "#fff" )
          .strokeStyle(function(d)  d.show && d.tr>0 ? "hsl("+d.tr*360.0+", 50%, 50%)"  : "#fff");


	 

    /* add focus select */

    /* Context panel (zoomed out). */
    context = vis.add(pv.Panel)
        .bottom(-10)
        .height(h2);

    /* X-axis ticks. */
    context.add(pv.Rule)
        .data(x.ticks())
        .left(x)
        .strokeStyle("#eee")
      .anchor("bottom").add(pv.Label)
      .font('13px Myriad Pro')
      .textStyle(pv.rgb(97,97,97,1))
        .text(x.tickFormat);



    /* Y-axis ticks. */
    context.add(pv.Rule)
        .bottom(0);

    /* Context area chart. */
    context.add(pv.Line)
      .data(small_data)
      .left(function(d) x(d.x))
      .bottom(function(d) y(d.y))
      //.fillStyle(pv.rgb(255, 102, 000, 0.25))
              //.anchor("top").add(pv.Line)
      .strokeStyle(pv.rgb(255,255,255,1))
      .lineWidth(0.5);


    /* The selectable, draggable focus region. */
    cPan= context.add(pv.Panel)
       .data([iR])
       .cursor("move")
       .events("all")
       .event("mousedown", pv.Behavior.drag())
	 .event("drag",function() {cPan.render(); focus.render();});


    cPan.add(pv.Bar)
        .left(0)
        .bottom(h2)
        .height(1)
        .width(function(d) d.x)
        .fillStyle(pv.rgb(255,255,255,1));
    cPan.add(pv.Bar)
        .left(0)
        .bottom(0)
        .height(h2)
        .width(function(d) d.x)
        .fillStyle(pv.rgb(255,255,255,0.6));

    cPan.add(pv.Bar)
        .left( function(d) d.x)
        .height(1)
        .bottom(0)
        .width(function(d) d.dx)
        .fillStyle(pv.rgb(255,255,255,1));

    cPan.add(pv.Bar)
        .left(function(d) d.x + d.dx)
        .bottom(h2)
        .height(1)
        .fillStyle(pv.rgb(255,255,255,1));
    cPan.add(pv.Bar)
        .left(function(d) d.x + d.dx)
        .bottom(0)
        .height(h2)
        .fillStyle(pv.rgb(255,255,255,0.6));

    cPan.add(pv.Panel)
      .left(function(d) d.x)
      .bottom(1)
      .height(h2 - 1)
      .width(function(d) d.dx);

  var leftDrag = cPan.add(pv.Bar)
        .left(function(d) d.x)
        .bottom(0)
        .height(h2)
        .width(1)
        .fillStyle(pv.rgb(255,255,255,1))
        .cursor("col-resize");

  var leftDot = leftDrag.add( pv.Dot)
        .left(function(d) d.x)
        .bottom(h2*0.5)
        .size(50)
        .strokeStyle(pv.rgb(0,0,0,1))
        .fillStyle(pv.rgb(255,255,255,1))
        .cursor("col-resize")
        .lineWidth(1);

      leftDot.event("mousedown",   pv.Behavior.resize("left"))
	  .event("resize", function() {cPan.render(); focus.render();});

    var rightDrag = cPan.add(pv.Bar)
        .left(function(d) d.dx+d.x)
        .bottom(0)
        .fillStyle(pv.rgb(255,255,255,1))
        .height(h2)
        .width(1)
        .cursor("col-resize");

    var rightDot=  rightDrag.add( pv.Dot)
        .left(function(d) d.x+d.dx)
        .bottom(h2*0.5)
        .size(50)
        .strokeStyle(pv.rgb(0,0,0,1))
        .fillStyle(pv.rgb(255,255,255,1))
        .cursor("col-resize")
        .lineWidth(1);


    rightDot.event("mousedown", pv.Behavior.resize("right"))
        .event("resize", function() {cPan.render(); focus.render();});
	
    vis.render();
	show_tooltips();

      loaded();
    }
  });
};

function setup_lightcurve_data_on_page(lightcurve){
  // $(".star_zone").html(lightcurve.source.kepler_fov_id);

  $(".star_mag").html(round_float(lightcurve.source.kepler_mag, 1));
  $(".star_temp").html(round_float(lightcurve.source.eff_temp, 1)+" (K)");
  $(".star_type").html(lightcurve.source.star_type);

  $(".star_radius").html(round_float(lightcurve.source.stellar_rad,1) +"x Sol");
  // $(".more_info").attr("href","/sources/"+lightcurve.source_id);
  $(".fav_link").click(function(event){
    event.preventDefault();
    $('.fav_link').html('<span class="fav"></span>'+"<%= t('.marking')%>");
      $.ajax({
        url: "/favourites",
        type: 'POST',
        dataType: 'json',
        data: {source_id: lightcurve.source_id},
        complete: (function(){ $(".fav_link").html('<span class="fav"></span>'+"<%= t('.marked_as_fav')%>"); })
      });
  });
   $(".download_link").attr("href", "/sources/"+lightcurve.source.zooniverse_id+".csv");
};

$('#zoom a').live('click', function(evt){
  evt.preventDefault();
  // switch($(this).attr('class')){
  //      case 'more':
  //        zoom_out = 0;
  //        zoom_in += 0.1;
  //        zoom = 1 + zoom_in;
  //        break;
  //      case 'less':
  //        zoom_in = 0;
  //        zoom_out += 0.1;
  //        zoom = 1 - zoom_out;
  //        break;
  //    };
 
  zoom_graph();
}).live('mouseenter', function(){
 $("#yZoom_help").show();
 }).live('mouseleave',function(){
 $("#yZoom_help").delay(1600).fadeOut(1600);

 });

function dblclick_zoom(){
  zoom_out = 0;
  zoom_in += 0.1;
  zoom = 1 + zoom_in;
  zoom_graph(pv.event)
};

function zoom_graph(evt){
  // zoomed_width  = w / zoom;
  //    zoomed_height = h / zoom;
  // 
  //    var
  //        offset = evt ? $(evt.srcElement).position() : {top: 0, left: 0};
  //        if(evt)
  //          center = { x: evt.layerX - offset.left, y: h - (evt.layerY - offset.top) };
  //        else
  //          center = { x: w / 2, y: h / 2};
  // 
  //    x.domain(x.invert(center['x'] - zoomed_width / 2),  x.invert(center['x'] + zoomed_width / 2));
  //    y.domain(y.invert(center['y'] - zoomed_height / 2), y.invert(center['y'] + zoomed_height / 2));
 
  vis.render();
};

var drag_start;
function pan_init(){
  drag_start = {
    x: pv.event.layerX,
    y: pv.event.layerY
  };

  drag_x = pv.Scale.linear(x.domain()[0], x.domain()[1]).range(0, w);
  drag_y = pv.Scale.linear(y.domain()[0], y.domain()[1]).range(0, h);
};

function pan_graph(){
  if (!drag_start) { return; };

  var
      t = {
        x: pv.event.layerX - drag_start['x'],
        y: pv.event.layerY - drag_start['y']
      };

  this.cursor('move');

  x.domain(drag_x.invert(0 - t.x), drag_x.invert(w - t.x));
  y.domain(drag_y.invert(0 + t.y), drag_y.invert(h + t.y));

  y_errors.data([]);
  dots.data(reduced_lg_data);
  vis.render();
};

function pan_end(){
  view.cursor('auto');
  drag_start = null;

  restore_graph();
};

function restore_graph(){
  y_errors.data(lightcurve_data);
  dots.data(lightcurve_data);
  vis.render();
};

function shuffle(array){
  var tmp, current, top = array.length;

  if(top) while(--top) {
      current = Math.floor(Math.random() * (top + 1));
      tmp = array[current];
      array[current] = array[top];
      array[top] = tmp;
  }
  return array;
};


$(function(){
  $(document).trigger('lightcurve_loaded', {load_graph: load_graph});
});

