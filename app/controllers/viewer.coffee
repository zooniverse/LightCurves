Spine = require('spine')

Lightcurve = require('models/lightcurve')

class Viewer extends Spine.Controller
  
  @width = 670
  @height = 440
  
  elements:
    '#graph': 'graph'
    '#zoom': 'zoom'
  
  # events:
  
  
  constructor: ->
    super
  
  teardown: => # Clean things up 
  
  active: ->
    super
    @render()
    
  render: =>
    @html require('views/lightcurve')(@)
  
  vis = undefined
  context = undefined
  focus = undefined
  data_points = undefined
  new_data = undefined
  small_data = undefined
  tiny_data = undefined
  view = undefined
  tutorial = false
  synthetic = false
  planet = false
  less_points = false
  select_bar = undefined
  select_active = false
  dots = undefined
  advanced_interface = false
  y_errors = undefined
  lightcurve_data = undefined
  reduced_lg_data = undefined
  zoom_anim_timer = undefined
  rel_shift = undefined
  guide = undefined
  t = undefined
  drag_x = undefined
  drag_y = undefined
  w = 670
  h = 440
  zoomed_width = 670
  zoomed_height = 440
  k = 3
  kx = w / h
  ky = 1
  x = pv.Scale.linear(-2, 36).range(0, w)
  y = pv.Scale.linear(1.007, 1.008).range(0, h)
  iR = undefined
  fx = undefined
  fy = undefined
  x_interval = x.domain()[1] - x.domain()[0]
  y_interval = y.domain()[1] - y.domain()[0]
  zoom = 1
  zoom_in = 0
  zoom_out = 0
  w = 670
  h1 = 400
  h2 = 30
  marked_transits = []
  cPan = undefined
  period = 9
  scaled = false  

  $(document).ready ->
    $("a.more").live "click", ->
      scaled = not scaled
      $(this).toggleClass "more"
      $(this).toggleClass "less"

    $("a.less").live "click", ->
      scaled = not scaled
      $(this).toggleClass "more"
      $(this).toggleClass "less"

  toggle_actual_transits = ->
    i = 0

    while i < new_data.length
      data[i].show = not data[i].show
      i++
    data_points.data data
    vis.render()
  
  # Zoom into a particular transit.  
  focus_transit = (transit_id, zoom) ->
    edit_container = $(".step .actions .edit")
    $(".transit").removeClass "focus"
    $(".transit .delete").fadeOut()
    $(".transit[title=" + transit_id + "]").addClass("focus").find(".delete").fadeIn()
    i = 0

    while i < marked_transits.length
      selected_id = i  if marked_transits[i].$properties[1].value[0].id is transit_id
      i++
    if zoom
      x_pos = marked_transits[selected_id].$properties[1].value[0].x
      dx = marked_transits[selected_id].$properties[1].value[0].dx
      ixs = (x(x_pos))
      ixe = (x(x_pos + Math.max(dx, 2)))
      less_points = true
      lT = Math.max(ixs - 2.0 * (ixe - ixs), 0)
      rT = Math.min(ixe + 2.0 * (ixe - ixs), 660)
      lStep = Math.abs(iR.x - lT) / 20.0
      rStep = Math.abs(iR.x + iR.dx - rT) / 20.0
      clearInterval zoom_anim_timer
      zoom_anim_timer = setInterval("zoom_amin(" + lT + "," + rT + "," + lStep + "," + rStep + ")", 10)

  #    iR =
  #      x: ixs - w * 2
  #      dx: w * 4

  #    cPan.data [iR]
  #    vis.render()
      
  anim_done = ->
    less_points = false
    vis.render()

  # Sets the zoom into a particular area. Called repeatedly for zoom, so we're going to want to change this.    
  zoom_amin = (targetL, targetR, stepL, stepR) ->
    xOld = iR.x
    dxOld = iR.dx
    if Math.abs((iR.x - targetL)) < stepL and Math.abs((iR.x + iR.dx) - targetR) < stepR
      anim_done()
      clearInterval zoom_anim_timer
      console.log "done"
    else
      startChange = 0
      if Math.abs((iR.x - targetL)) > stepL
        if iR.x > targetL
          iR.x = iR.x - stepL
        else
          iR.x = iR.x + stepL
      if Math.abs(((iR.x + iR.dx) - targetR)) > stepR
        if (iR.x + iR.dx) > targetR
          iR.dx = xOld - iR.x + dxOld - stepR
        else
          iR.dx = xOld - iR.x + dxOld + stepR
      cPan.data [iR]
      cPan.render()
      focus.render()    

  # Remove a marked transit.
  remove_transit_box = (id) ->
    selected_id = undefined
    i = 0

    while i < marked_transits.length
      selected_id = i  if marked_transits[i].$properties[1].value[0].id is id
      i++
    marked_transits[selected_id].data []
    marked_transits.splice selected_id, 1
    vis.render()

  # Mark a transit.    
  add_transit_box = (x, y, dx, dy, auto) ->
    xDom = fx.domain()
    yDom = fy.domain()
    s_x = undefined
    s_y = undefined
    s_height = undefined
    s_width = undefined
    transit_no = marked_transits.length + 1
    transit_no = 1  unless transit_no?
    if auto
      width = Math.abs(xDom[xDom.length - 1] - xDom[0]) / 8.0
      height = Math.abs(yDom[yDom.length - 1] - yDom[0]) / 2.0
      xMid = (xDom[xDom.length - 1] + xDom[0]) / 2.0 - 0.5 * width
      yMid = (yDom[yDom.length - 1] + yDom[0]) / 2.0 - 0.5 * height
      if marked_transits.length is 0
        s_x = xMid
        s_y = yMid
        s_width = width
        s_height = height
      else
        s_x = xMid
        s_y = yMid
        s_width = marked_transits[marked_transits.length - 1].$properties[1].value[0].dx
        s_height = marked_transits[marked_transits.length - 1].$properties[1].value[0].dy
    else if dx > 10 and dy > 10 and auto is false
      s_width = fx.invert(x + dx) - fx.invert(x)
      s_height = fy.invert(y + dy) - fy.invert(y)
      s_x = fx.invert(x)
      s_y = (yDom[yDom.length - 1] - (fy.invert(y) - yDom[0])) - s_height
    else
      select_bar.fillStyle "rgba(255, 128, 128, 0)"
      focus.render()
      return null
    transit_pan = focus.add(pv.Panel).def("show_guide", ->
      1
    ).data([
      x: s_x
      y: s_y
      dx: s_width
      dy: s_height
      id: transit_no
      add_type: auto
    ]).overflow("hidden").event("mousedown", pv.Behavior.scaled_drag(fx, fy)).event("click", (d) ->
      focus_transit(d.id, false)
    )
    
    #.event("child_resize", pv.Behavior.scaled_resize("bottom right",fx,fy));
    transit = transit_pan.add(pv.Bar).left((d) ->
      fx(d.x)
    ).bottom((d) ->
      fy(d.y)
    ).width((d) ->
      fx(d.x + d.dx) - fx(d.x)
    ).height((d) ->
      fy(d.y + d.dy) - fy(d.y)
    ).fillStyle(pv.rgb(150, 150, 150, .15)).strokeStyle("#09C").lineWidth(4).cursor("move")
    
    #show guides 
    if period? and advanced_interface
      transit_pan.event("mouseover", ->
        transit_pan.show_guide 1
        $(".star_name").html("possible extra transits with period " + period).show().delay(3200).fadeOut 1600
        transit_pan.render()
      ).event "mouseout", ->
        @show_guide(-1)

      l = -5

      while l < 5
        unless l is 0
          transit_pan.add(pv.Panel).add(pv.Bar).def("off", period * (l)).left((d) ->
            fx(d.x + @off())
          ).bottom((d) ->
            fy(0)
          ).width((d) ->
            fx(d.x + d.dx) - fx(d.x)
          ).height((d) ->
            fy(10)
          ).fillStyle(->
            (if transit_pan.show_guide() is 1 then "rgba(255, 128, 128, .1)" else "rgba(255, 128, 128, 0)")
          ).events "none"
        l++
    drag_corner = transit_pan.add(pv.Bar).left((d) ->
      fx(d.x + d.dx) - 10
    ).bottom((d) ->
      fy(d.y)
    ).width(10).height(10).cursor("se-resize").fillStyle("#09C").event("mousedown", pv.Behavior.scaled_resize("", fx, fy)).event("resize", transit_pan)
    transit.anchor("left").add(pv.Dot).size(100).strokeStyle("#09C").fillStyle("#FFF").lineWidth(3).anchor("center").add(pv.Label).text(transit_no).font "14px sans-serif"
    transit.anchor("center").add(pv.Dot).size(4).fillStyle "#09C"
    marked_transits.push transit_pan
    transit = $("<div/>",
      id: "transit" + transit_no
      class: "transit active"
    )
    create_transit_button transit_no
    get_transit_coords()
    select_bar.fillStyle "rgba(255, 128, 128, 0)"
    focus.render()
    transit

  # Create transit button? Seems to be click to add transit.    
  create_transit_button = (transit_number) ->
    edit_container = $(".step .actions .edit")
    number = edit_container.find(".transit:first-child").clone().data("transit_id", "transit" + transit_number).attr("title", transit_number).text(transit_number).css("display", "inline-block").append($("<a/>",
      class: "delete"
      href: "#"
      title: "delete"
    ).click((evt) ->
      evt.preventDefault()
      number = $(this).parent().attr("title")
      remove_transit_box number
      $(".transit.focus").fadeOut ->
        $(this).remove()

      $(this).parent().fadeOut ->
        $(this).remove()

    ))
    edit_container.find(".add").before number
    number.click ->
      focus_transit transit_number, true

  # Pulls down transit coords into a js object.
  get_transit_coords = ->
    transit_coords = []
    i = 0

    while i < marked_transits.length
      values = marked_transits[i].$properties[1].value[0]
      transit_coords.push
        marker_id: values.id
        x: values.x
        y: values.y
        width: values.dx
        height: values.dy
        add_type: values.add_type

      i++
    transit_coords
    
#  loading = ->
#    $("#graph").html "<%=image_tag \"spinner.gif\", :class=>\"spinner\"%>"
    
  loaded = ->
    $(".graph .loading").hide()
    
  show_tooltips = ->
    $("#xZoom_help").show().delay(3200).fadeOut 1600
    $("#yZoom_help").show().delay(3200).fadeOut 1600
    
  show_transit_tooltips = ->
    $("#drag_help").show().delay(3200).fadeOut 1600
    
  addSelectBar = ->
    select_bar = focus.add(pv.Panel).data([
      x: 0
      y: 0
      dx: 0
      dy: 0
    ]).cursor("crosshair").events("all").event("mousedown", pv.Behavior.select()).event("selectstart", (d) ->
      select_bar.fillStyle("rgba(255, 128, 128, 0.4)")
    ).event("selectend", (d) ->
      add_transit_box d.x, (d.y), d.dx, d.dy, false
    ).add(pv.Bar).left((d) ->
      d.x
    ).width((d) ->
      d.dx
    ).top((d) ->
      (d.y)
    ).height((d) ->
      d.dy
    ).fillStyle("rgba(255, 128, 128, .4)")
    vis.render()

  # Load the JSON from a lightcurve into data.
  load_graph = (target_light_curve) ->
    loading()
    vis = new pv.Panel().canvas("graph").width(w).height(h).top(5).bottom(30).left(50).right(5)
    marked_transits = []
    tutorial = true  if "<%=lightcurve%>" is "tutorial_light_curve"
    
    # originally an ERB line
    lightcurve = "next_light_curve/?lightcurve_id=#{@source_select}"  if @source_select
    
    target_light_curve = "<%=lightcurve%>"  if typeof target_light_curve is "undefined"
    $.ajax
      url: "/light_curves/" + target_light_curve
      error: ->
        $(".spinner").remove()
        $(".workflow").html " <div class='step step0' style='margin-top:100px;'><p class='question'><%=t('lightcurve.all_done')%></p></div>"
        $(".step0").show()
        $(".more_info").hide()
        $("#favorite_and_download").hide()

      success: (objJson) ->
        classification =
          light_curves: [objJson.light_curve.id]
          annotations: []

        $(document).trigger "loading",
          lightcurve: objJson.light_curve

        if objJson.light_curve.source.kind is "simulation"
          synthetic = true
        else planet = true  if objJson.light_curve.source.kind is "planet"
        priority = objJson.light_curve.priority
        rel_shift = objJson.light_curve.rel_start_time
        setup_lightcurve_data_on_page objJson.light_curve
        load_light_curve_data objJson.light_curve.light_curve_url

  round_float = (x, n) ->
    n = 0  unless parseInt(n)
    return false  unless parseFloat(x)
    Math.round(x * Math.pow(10, n)) / Math.pow(10, n)

  load_light_curve_data = (light_curve_url) ->
    light_curve_url = "/tutorial_light_curve.json"  if tutorial
    $.jsonp
      callback: "light_curve_data"
      url: light_curve_url
      error: ->
        alert "<%=t('lightcurve.failed_to_get')%>" + light_curve_url

      success: (objJson) ->
        alert "<%=t('lightcurve.problem')%>"  if not objJson or objJson.length <= 0
        data = objJson
        data = data.data  if data.meta_data
        if @shift_time #ERB Line
          i = 0

          while i < data.length
            data[i].x = data[i].x + rel_shift
            i++
        no_points = data.length
        new_data = []
        small_data = []
        tiny_data = []
        ymax = 0
        ymin = 1000000
        i = 0

        while i < no_points
          if data[i].y > 0
            tr = (if synthetic or tutorial then Math.floor(data[i].tr) else 0)
            y = (if synthetic or priority then data[i].y * 1.008 else data[i].y)
            dy = (if synthetic then data[i].dy else data[i].dy)
            data_with_transits =
              x: ((if data[i].x < 1000 then data[i].x else data[i].x - data[0].x))
              y: y
              dy: dy
              tr: tr
              show: false
              s: tr

            small_data.push data_with_transits  if i % 3 is 0
            tiny_data.push data_with_transits  if i % 8 is 0
            new_data.push data_with_transits
            ymax = data_with_transits.y  if data_with_transits.y > ymax
            ymin = data_with_transits.y  if data_with_transits.y < ymin
          i++
        data = null
        
        if @transits # ERB Line
          $("#graph").after "<div id='color_bar'></div>"
          $("#color_bar").append "<ul style='width:725px; height:30px; list-style-type:none;;'>"
          i = 1

          while i < 100
            $("#color_bar").append "<li style='width:20px; height:30px; float:left; background-color:hsl(" + i * 360.0 / (100.0) + ",50%,50%); font-size:10pt;list-style-type:none;'>" + i + "</li>"
            i += 2
          $("#color_bar").append "</ul>"
          i = 0

          while i < new_data.length
            new_data[i].tr = 0
            i++
          transits = @transits.to_json.html_safe # ERB Line
          i = 0

          while i < transits.length
            transit = transits[i]
            j = 0

            while j < new_data.length
              new_data[j].show = true
              # ERB on classification_count
              new_data[j].tr += 1.0 / @classification_count  if new_data[j].x > transit.x and new_data[j].x < transit.x + transit.width and new_data[j].y > transit.y and new_data[j].y < transit.y + transit.height
              j++
            i++
            
        data = new_data
        no_points = data.length
        start = new_data[0].x #- 0.05* (new_data[no_points-1].x - new_data[0].x );
        end = new_data[no_points - 1].x #+ 0.05* (new_data[no_points-1].x - data[0].x );
        yrange = ymax - ymin
        ymax = ymax + 0.15 * yrange
        ymin = ymin - 0.15 * yrange
        
        # Scales and sizing. 
        x = pv.Scale.linear(start, end).range(0, w)
        y = pv.Scale.linear(ymin, ymax).range(0, h2)
        
        # Interaction state. Focus scales will have domain set on-render. 
        iR =
          x: 0
          dx: 660

        fx = pv.Scale.linear().range(0, w)
        fy = pv.Scale.linear().range(0, h1)
        
        # fy.domain(y.domain());
        focus = vis.add(pv.Panel).def("init", ->
          d1 = x.invert(iR.x)
          d2 = x.invert(iR.x + iR.dx)
          ld = ((if less_points then tiny_data else new_data))
          dd = ld.slice(Math.max(0, pv.search.index(ld, d1, (d) ->
            d.x
          ) - 1), pv.search.index(ld, d2, (d) ->
            d.x
          ) + 1)
          fx.domain d1, d2
          if scaled
            max = pv.deviation(dd, (d) ->
              d.y
            ) * 3.0 + pv.mean(dd, (d) ->
              d.y
            )
            min = pv.min(dd, (d) ->
              d.y
            )
            width = max - min
            fy.domain [min - (0.15) * (max - min), max - 0.05 * (max - min)]
          else
            fy.domain y.domain()
          dd
        ).top(0).height(h1)
        focus.add(pv.Rule).data(->
          fx.ticks()
        ).left(fx).strokeStyle(pv.rgb(68, 68, 68, 1)).strokeDasharray("1,4").anchor("bottom").add(pv.Label).text(fx.tickFormat).strokeStyle("#FFF").textStyle pv.rgb(97, 97, 97, 1)
        
        # Y-axis ticks. 
        focus.add(pv.Rule).data(->
          fy.ticks(7)
        ).bottom(fy).strokeStyle(pv.rgb(68, 68, 68, 1)).strokeDasharray("1,4").anchor("left").add(pv.Label).text(fy.tickFormat).left(-10).font("10px Myriad Pro").textStyle pv.rgb(97, 97, 97, 1)
        
        # Focus area chart. 
        
        # .overflow("hidden")
        y_errors = focus.add(pv.Panel).add(pv.Rule).data(->
          focus.init()
        ).left((d) ->
          fx(d.x)
        ).bottom((d) ->
          fy(d.y - d.dy)
        ).height((d) ->
          fy(d.y + d.dy) - fy(d.y - d.dy)
        ).lineWidth(1.00).strokeStyle(pv.rgb(239, 239, 239, 0.1))
        data_points = focus.add(pv.Dot).data(->
          focus.init()
        ).left((d) ->
          fx(d.x)
        ).bottom((d) ->
          fy(d.y)
        ).size(3).fillStyle((d) ->
          (if d.show and d.tr > 0 then "hsl(" + d.tr * 360.0 + ", 50%, 50%)" else "#fff")
        ).strokeStyle((d) ->
          (if d.show and d.tr > 0 then "hsl(" + d.tr * 360.0 + ", 50%, 50%)" else "#fff")
        )
        
        # add focus select 
        
        # Context panel (zoomed out). 
        context = vis.add(pv.Panel).bottom(-10).height(h2)
        
        # X-axis ticks. 
        context.add(pv.Rule).data(x.ticks()).left(x).strokeStyle("#eee").anchor("bottom").add(pv.Label).font("13px Myriad Pro").textStyle(pv.rgb(97, 97, 97, 1)).text x.tickFormat
        
        # Y-axis ticks. 
        context.add(pv.Rule).bottom 0
        
        # Context area chart. 
        
        #.fillStyle(pv.rgb(255, 102, 000, 0.25))
        #.anchor("top").add(pv.Line)
        context.add(pv.Line).data(small_data).left((d) ->
          x(d.x)
        ).bottom((d) ->
          y(d.y)
        ).strokeStyle(pv.rgb(255, 255, 255, 1)).lineWidth 0.5
        
        # The selectable, draggable focus region. 
        cPan = context.add(pv.Panel).data([iR]).cursor("move").events("all").event("mousedown", pv.Behavior.drag()).event("drag", ->
          cPan.render()
          focus.render()
        )
        cPan.add(pv.Bar).left(0).bottom(h2).height(1).width((d) ->
          d.x
        ).fillStyle pv.rgb(255, 255, 255, 1)
        cPan.add(pv.Bar).left(0).bottom(0).height(h2).width((d) ->
          d.x
        ).fillStyle pv.rgb(255, 255, 255, 0.6)
        cPan.add(pv.Bar).left((d) ->
          d.x
        ).height(1).bottom(0).width((d) ->
          d.dx
        ).fillStyle pv.rgb(255, 255, 255, 1)
        cPan.add(pv.Bar).left((d) ->
          d.x + d.dx
        ).bottom(h2).height(1).fillStyle pv.rgb(255, 255, 255, 1)
        cPan.add(pv.Bar).left((d) ->
          d.x + d.dx
        ).bottom(0).height(h2).fillStyle pv.rgb(255, 255, 255, 0.6)
        cPan.add(pv.Panel).left((d) ->
          d.x
        ).bottom(1).height(h2 - 1).width (d) ->
          d.dx

        leftDrag = cPan.add(pv.Bar).left((d) ->
          d.x
        ).bottom(0).height(h2).width(1).fillStyle(pv.rgb(255, 255, 255, 1)).cursor("col-resize")
        leftDot = leftDrag.add(pv.Dot).left((d) ->
          d.x
        ).bottom(h2 * 0.5).size(50).strokeStyle(pv.rgb(0, 0, 0, 1)).fillStyle(pv.rgb(255, 255, 255, 1)).cursor("col-resize").lineWidth(1)
        leftDot.event("mousedown", pv.Behavior.resize("left")).event "resize", ->
          cPan.render()
          focus.render()

        rightDrag = cPan.add(pv.Bar).left((d) ->
          d.dx + d.x
        ).bottom(0).fillStyle(pv.rgb(255, 255, 255, 1)).height(h2).width(1).cursor("col-resize")
        rightDot = rightDrag.add(pv.Dot).left((d) ->
          d.x + d.dx
        ).bottom(h2 * 0.5).size(50).strokeStyle(pv.rgb(0, 0, 0, 1)).fillStyle(pv.rgb(255, 255, 255, 1)).cursor("col-resize").lineWidth(1)
        rightDot.event("mousedown", pv.Behavior.resize("right")).event "resize", ->
          cPan.render()
          focus.render()

        vis.render()
        show_tooltips()
        loaded()

  setup_lightcurve_data_on_page = (lightcurve) ->  
    # $(".star_zone").html lightcurve.source.kepler_fov_id
    $(".star_mag").html round_float(lightcurve.source.kepler_mag, 1)
    $(".star_temp").html round_float(lightcurve.source.eff_temp, 1) + " (K)"
    $(".star_type").html lightcurve.source.star_type
    $(".star_radius").html round_float(lightcurve.source.stellar_rad, 1) + "x Sol"
    
    # $(".more_info").attr("href","/sources/"+lightcurve.source_id);
    $(".fav_link").click (event) ->
      event.preventDefault()
      $(".fav_link").html "<span class=\"fav\"></span>" + "<%= t('.marking')%>"
      $.ajax
        url: "/favourites"
        type: "POST"
        dataType: "json"
        data:
          source_id: lightcurve.source_id

        complete: (->
          $(".fav_link").html "<span class=\"fav\"></span>" + "<%= t('.marked_as_fav')%>"
        )


    $(".download_link").attr "href", "/sources/" + lightcurve.source.zooniverse_id + ".csv"
      
  $("#zoom a").live("click", (evt) ->
    evt.preventDefault()
          
  #  switch $(this).attr("class")
  #    when "more"
  #      zoom_out = 0
  #      zoom_in += 0.1
  #      zoom = 1 + zoom_in
  #    when "less"
  #      zoom_in = 0
  #      zoom_out += 0.1
  #      zoom = 1 - zoom_out
  #    dblclick_zoom = ->
  #      zoom_out = 0
  #      zoom_in += 0.1
  #      zoom = 1 + zoom_in
  #      zoom_graph pv.event

    zoom_graph()
  ).live("mouseenter", ->
    $("#yZoom_help").show()
  ).live "mouseleave", ->
    $("#yZoom_help").delay(1600).fadeOut 1600

  zoom_graph = (evt) ->
  #  zoomed_width = w / zoom
  #  zoomed_height = h / zoom
  #  offset = (if evt then $(evt.srcElement).position() else
  #    top: 0
  #    left: 0
  #  )
  #  if evt
  #    center =
  #      x: evt.layerX - offset.left
  #      y: h - (evt.layerY - offset.top)
  #  else
  #    center =
  #      x: w / 2
  #      y: h / 2
  #  x.domain x.invert(center["x"] - zoomed_width / 2), x.invert(center["x"] + zoomed_width / 2)
  #  y.domain y.invert(center["y"] - zoomed_height / 2), y.invert(center["y"] + zoomed_height / 2)
    vis.render()

  pan_init = ->
    drag_start =
      x: pv.event.layerX
      y: pv.event.layerY

    drag_x = pv.Scale.linear(x.domain()[0], x.domain()[1]).range(0, w)
    drag_y = pv.Scale.linear(y.domain()[0], y.domain()[1]).range(0, h)
    
  pan_graph = ->
    return  unless drag_start
    t =
      x: pv.event.layerX - drag_start["x"]
      y: pv.event.layerY - drag_start["y"]

    @cursor "move"
    x.domain drag_x.invert(0 - t.x), drag_x.invert(w - t.x)
    y.domain drag_y.invert(0 + t.y), drag_y.invert(h + t.y)
    y_errors.data []
    dots.data reduced_lg_data
    vis.render()
    
  pan_end = ->
    view.cursor "auto"
    drag_start = null
    restore_graph()
    
  restore_graph = ->
    y_errors.data lightcurve_data
    dots.data lightcurve_data
    vis.render()
    
  shuffle = (array) ->
    tmp = undefined
    current = undefined
    top = array.length
    if top
      while --top
        current = Math.floor(Math.random() * (top + 1))
        tmp = array[current]
        array[current] = array[top]
        array[top] = tmp
    array
    
  drag_start = undefined

  $ ->
    $(document).trigger "lightcurve_loaded",
      load_graph: load_graph
          
module.exports = Lightcurves
