Spine = require('spine')

LightcurveData = require 'models/lightcurveData'
LightcurveMeta = require 'models/lightcurveMeta'

class Viewer extends Spine.Controller
  
  elements:
    '#zoom': 'zoomBtn'
    
  events:
    'click #zoom a': 'zoom'
    'mouseenter #zoom a': -> $("#yZoom_help").show()
    'mouseleave #zoom a': -> $("#yZoom_help").delay(1600).fadeOut 1600
  
  constructor: ->
    super
    @el.attr("id", "graph")

    @width = 670
    @height = 440  
    @h_graph = 400
    @h_bottom = 30
  
    @max_zoom = 10
      
    # Add spinner in future  
    @loading = false      
  
  teardown: -> # Clean things up 
    
  render: =>    
    @html require('views/lightcurve')(@)          
  
  loadData: (json, meta) =>
    alert(t('lightcurve.problem')) if not json or json.length <= 0
    
    @lcData = new LightcurveData(data: json, meta: meta)
    
    @x_graph = d3.scale.linear() 
      .domain([@lcData.start, @lcData.end])
      .range([0, @width])
    
    @y_graph = d3.scale.linear()
      .domain([@lcData.ymin, @lcData.ymax])
      .range([0, @h_graph])
  
    @x_bottom = d3.scale.linear()
      .domain([@lcData.start, @lcData.end])
      .range([0, @width])
    @y_bottom = d3.scale.linear()
      .domain([@lcData.ymin, @lcData.ymax])
      .range([0, @h_bottom])
    
    @zoom_graph = d3.behavior.zoom()
      .x(@x_graph)
      .scaleExtent([1, @max_zoom])
      .on("zoom", @graph_zoom)
      
    @zoom_bottom = d3.behavior.zoom()
      .x(@x_bottom)
      .scaleExtent([1, @max_zoom])   
      .on("zoom", @bottom_zoom)
  
    @canvas = d3.select("#graph_canvas")      
    .attr("width", @width)
    .attr("height", @h_graph)
    .call(@zoom_graph)
    .node().getContext("2d")        
    
    @graph_zoom() 
    
  zoom: (ev) ->
    ev.preventDefault()
    alert "click"
    # do stuff
  
  graph_zoom: =>
    data = @lcData.data    
    @canvas.clearRect(0, 0, @width, @h_graph)
            
    i = -1
    n = data.length
    h = @h_graph
    @canvas.beginPath()    
    while ++i < n
      d = data[i]
      cx = @x_graph(d.x)
      cy = h - @y_graph(d.y)
      @canvas.moveTo(cx, cy)
      @canvas.arc(cx, cy, 2.5, 0, 2 * Math.PI)
    
    @canvas.fillStyle = "#FFFFFF"          
    @canvas.fill()
    
  bottom_zoom: =>
    alert "bottom zoom"

          
module.exports = Viewer
