class Sheet
  @minWidth: 40
  @options:
    rowHeight: 18
    editable: false
    enableAddRow: false
    headerRowHeight: 0
    showHeaderRow: false
    enableCellNavigation: false
    multiColumnSort: false
  @dataViewId: '__id__'
  constructor: (@target, @columns, options)->
    @options = $.extend {}, options, Sheet.options
    @name = @options['name']
    delete @options['name']

    sheetId = @target.find('div.sheet').length

    # sheet body
    @sheet = $($('#sheet-template').html())
      .attr('id', "sheet#{sheetId}").appendTo @target
    @sheet.data('self', this)

    # sheet tag
    $tab = $('<li>').append($('<a>', {href: "#sheet#{sheetId}", 'data-toggle': 'tab'}).text("sheet #{sheetId}")).appendTo @target.prev()
    @target.prev().find('a:first').tab('show')

    @header = @sheet.find('.sheet-header')
    @body = @sheet.find('.sheet-body')

    # set header
    @header.find('h2').text(@name)
    group = new Operation.Group(this)
    filter = new Operation.Filter(this)
    field = new Operation.Field(this)
    chart = new Operation.Chart(this)
    transform = new Operation.Transform(this)
    
    @header.find('.btn').on 'click', (ev)=>
      role = $(ev.target).data('role')
      if role is 'filter'
        filter.bootup(this)
      else if role is 'addfield'
        field.bootup(this)
      else if role is 'group'
        group.bootup(this)
      else if role is 'chart'
        chart.bootup(this)
      else if role is 'transform'
        transform.bootup(this)

    
    # check columns
    if not Array.isArray(@columns)
      @columns = [@columns]

    # create dataview
    @dataView = new Slick.Data.DataView({ inlineFilters: true })
    
    @grid = new Slick.Grid(@body, @dataView, @columns, @options)
    
    @grid.setSelectionModel(new Slick.RowSelectionModel())
    @dataView.onRowCountChanged.subscribe (e, args)=>
      @grid.updateRowCount()
      @grid.render()
    @dataView.syncGridSelection(@grid, true)

    # header menu
    headerMenuPlugin = new Slick.Plugins.HeaderMenu({})
    headerMenuPlugin.onBeforeMenuShow.subscribe (e, args)=>
      menu = args.menu
      
    new Operation.Sort(this)
    headerMenuPlugin.onCommand.subscribe (ev, args)=>
      if this[args.command]?
        this[args.command](ev, args)
        

    @grid.registerPlugin(headerMenuPlugin)

    @grid.init()
    

  # setter/getter
  columns: ()->
    return @columns
    
  group: (group)->
    if not group
      return @group
    else
      @group = group

  filter: (filter)->
    if not filter
      return @filter
    else
      @filter = filter

  addItems: (data, uniqId)->
    @dataView.beginUpdate()
    @dataView.setItems(data, uniqId or Sheet.dataViewId)
    @dataView.endUpdate()

  # action
  refresh: ()->
  render: ()->

  addColumn: (field)->
    @columns = @grid.getColumns()
    column =
      id: field
      name: field
      field: field
      width: Sheet.minWidth
      sortable: true
      header:
        menu: 
          items: [
            {
              iconImage: '/vendor/slickgrid/images/sort-asc.gif'
              title: 'sort asc'
              command: 'Sort.asc'
            }
            {
              iconImage: '/vendor/slickgrid/images/sort-desc.gif'
              title: 'sort desc'
              command: 'Sort.desc'
            }
            {
              iconImage: null
              title: 'filter'
              command: 'Filter.field'
            }
          ]
    @columns.push column
    @grid.setColumns(@columns)

  @createColumns: (header)->
    columns = []
    for field in header
      if field is Sheet.delimiter
        continue
      columns.push {
        id: field
        name: field
        field: field
        width: Sheet.minWidth
        sortable: true
        header:
          menu:
            items: [
              {
                iconImage: '/vendor/slickgrid/images/sort-asc.gif'
                title: 'sort asc'
                command: 'Sort.asc'
              }
              {
                iconImage: '/vendor/slickgrid/images/sort-desc.gif'
                title: 'sort desc'
                command: 'Sort.desc'
              }
              {
                iconImage: null
                title: 'filter'
                command: 'Filter.field'
              }
            ]
      }

    columns
    