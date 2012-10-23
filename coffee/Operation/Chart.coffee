Operation.Chart = class Chart
  constructor: (@sheet)->
    @modal = Chart.modal

  bootup: (@sheet)->
    Chart.sheet = @sheet
    $('#graph .modal-body').children().remove()
    @modal.find('.modal-footer .exec').one 'click', ()=>
      type = @modal.find('#charttype').val()
      if not Chart.ChartType[type]?
        return
      attrs = {}
      attrs[Chart.ChartType[type]?.attrs[idx].val] = $(select).val() for select, idx in @modal.find('#chartsettings').find('select')
      Chart.ChartType[type]?.func.call(this, attrs)
  checkType: (val)->
    if (if Number(val)? then new Date(val-0) else new Date(val))?
      return if Number(val) then new Date(val-0) else new Date(val)
    else if Number(val)?
      return Number(val)
    else
      return val

  @ChartType:
    line:
      func: (attrs)->
        data = []
        dataView = @sheet.grid.getData()
        for row in dataView.getItems()
          obj = {}
          for attr, val of attrs
            if row[val]?
              if attr is 'x'
                v = @checkType(row[val])
              else
                v = row[val]
              obj[attr] = v
          data.push obj

        colors = d3.scale.category20()
        svg = d3.select('#graph .modal-body').append('svg').attr('height', 400)
        x = d3.scale.linear().range([0, 400]).domain(d3.extent(data, (d)-> d.x))
        y = d3.scale.linear().range([400, 0]).domain(d3.extent(data, (d)-> d.y))
        line = d3.svg.line()
          .x((d)-> x(d.x))
          .y((d)-> y(d.y))

        svg.append('path')
          .datum(data)
          .style('stroke', colors(0))
          .style('fill', 'none')
          .attr('d', line)

        $('#graph').modal('show')
        
      attrs: [
        {name: 'xAxis', val: 'x'}
        {name: 'yAxis', val: 'y'}
        {name: 'series', val: 's'}
      ]
    stack: null
    bar: null
    tree: null
    scatter:
      func: (attrs)->
        data = []
        dataView = @sheet.grid.getData()
        for row in dataView.getItems()
          obj = {}
          for attr, val of attrs
            if row[val]?
              if attr is 'cx'
                v = @checkType(row[val])
              else
                v = row[val]
              obj[attr] = v
          data.push obj
          
        colors = d3.scale.category20()
        svg = d3.select('#graph .modal-body').append('svg').attr('height', 400)
        x = d3.scale.linear().range([0, 400]).domain(d3.extent(data, (d)-> d.cx))
        y = d3.scale.linear().range([400, 0]).domain(d3.extent(data, (d)-> d.cy))
        r = d3.scale.linear().range([5, 20]).domain(d3.extent(data, (d)-> d.r * d.r))

        svg.selectAll('circle')
          .data(data).enter()
          .append('circle')
          .attr('cx', (d)-> x(d.cx))
          .attr('cy', (d)-> y(d.cy))
          .attr('r', (d)-> r(d.r * d.r))
          .style('fill', (d)-> colors(d.group))
          .style('opacity', .5)

        $('#graph').modal('show')
        
      attrs: [
        {name: 'xAxis', val: 'cx'}
        {name: 'yAxis', val: 'cy'}
        {name: 'size', val: 'r'}
        {name: 'group', val: 'group'}
      ]
        
    pie: 
      func: (attrs)->
        data = []
        dataView = @sheet.grid.getData()
        for row in dataView.getItems()
          obj = {}
          for attr, val of attrs
            if row[val]?
              obj[attr] = row[val]
          data.push obj

        colors = d3.scale.category20()
        arc = d3.svg.arc()
          .outerRadius(190)
          .innerRadius(0)
          
        svg = d3.select('#graph .modal-body').append('svg')
          .attr('height', 400)
          .append('g')
          .attr('transform', 'translate(200,200)')
        pie = d3.layout.pie()
          .sort(null)
          .value((d)-> d.value)
        g = svg
          .selectAll('.arc')
          .data(pie(data)).enter()
          .append('g')
          .attr('class', 'arc')
          
        g.append('path')
          .attr('d', arc)
          .attr('fill', (d)-> colors(d.data.text))
          

        $('#graph').modal('show')
      attrs: [
        {name: 'label', val: 'text'}
        {name: 'value', val: 'value'}
      ]
    heatmap: 
      func: ()->
        data = []
        dataView = @sheet.grid.getData()
        for row in dataView.getItems()
          obj = {}
          for attr, val of attrs
            if row[val]?
              obj[attr] = row[val]
          data.push obj

        colors = d3.scale.category20()
        treemap = d3.layout.treemap()
          .round(false)
          .size([400, 400])
          .sticky(true)
          .value((d)-> d.value)
          
        svg = d3.select('#graph .modal-body').append('svg')
          .attr('height', 400)
          .append('div').attr('class', 'chart')
          .style('width', '400px')
          .style('height', '400px')
          .append('svg:svg')
          .attr('width', 400)
          .attr('height', 400)
          .append('svg:g')
          .attr('transform', 'translate(.5,.5)')


        $('#graph').modal('show')
      attrs: [
        {name: 'xAxis', val: 'x'}
        {name: 'yAxis', val: 'y'}
        {name: 'value', val: 'value'}
      ]

  @genFieldSelect: (attr)->
    select = $('<select>', {type: 'text', id: "chart-attr-#{attr}", name: "chartattr#{attr}"})
    field = $('<div>', {class: 'controls'}).append select
    select.append($('<option>').text(''))
    if Chart.sheet?
      for column in @sheet.grid.getColumns()
        if column.field isnt Sheet.dataViewId
          select.append($('<option>', {value: column.field}).text(column.field))
    field

  @onChangeChartType: (ev)=>
    type = @modal.find('#charttype').val()
    @settings.children().remove()
    if Chart.ChartType[type]?
      for attr in Chart.ChartType[type].attrs
        @settings.append $('<fieldset>').append(
          $('<div>', {class: 'control-group'}).append(
            $('<label>', {class: 'control-label', for: "chart-attr-#{attr}"}).text(attr.name)
            @genFieldSelect(attr)
          )
        )
  @init: (@modal)->
    @modal = $(@modal)
    @settings = @modal.find('#chartsettings')

    for type, impl of @ChartType
      if impl?
        @modal.find('#charttype').append $('<option>', {value: type}).text(type)

    @modal.find('#charttype').on 'change', @onChangeChartType
