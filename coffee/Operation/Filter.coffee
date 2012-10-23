Operation.Filter = class Filter
  constructor: (@sheet)->
#     @modal = Filter.modal
#     @columns = @sheet.grid.getColumns()
#     @dataView = @sheet.dataView
    
    # append default value

  exec: ()=>
    begin = new Date()
    # group by elements

      
  @delimiter: '__$__'
  @bootup: ()=>

  @cleanup: ()=>
    
  @init: (@modal)->
    @modal.on 'show', @bootup
    @modal.on 'hide', @cleanup

