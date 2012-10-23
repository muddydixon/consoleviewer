Operation.Field = class Field
  constructor: ()->
  exec: ()=>
    rows = @modal.find('form table tbody tr')
    fieldList = (($(input).val() for input in $(row).find('input')) for row in rows)

    for fieldDef in fieldList
      [field, rowFunction] = fieldDef
      
      @dataView = @sheet.grid.getData()
      rowFunc = Field.genRowFunction rowFunction
      for data in @dataView.getItems()
        data[field] = rowFunc.call(data)
      @sheet.addColumn(field)
      
    @modal.modal('hide')    
    return false
    
  delimiter: '__$__'
  bootup: (@sheet)=>
    @modal = Field.modal

    @modal.find('form table tbody').append Field.newSelectRow()
    
    @modal.find('.modal-footer .exec').one 'click', @exec

  @cleanup: ()=>
    @modal.find('form table tbody tr').remove()
    @modal.find('.modal-footer .exec').off 'click'
    
  @newSelectRow: ()->
    $tr = $('<tr>', {class: 'fieldDesc'})
    $tr.append $('<td>').append $('<input>', {type: 'input', class: 'input-small', name: 'field'})
    $tr.append $('<td>').append $('<input>', {type: 'input', class: 'input', name: 'inrowfunction'})
    $tr.append $('<td>').append $('<a>', {class: 'close'}).html('&times;')
    return $tr
    
  @init: (@modal)->
    @modal = $(@modal)
    
    @modal.find('form .addValue').on 'click', ()=>
      @modal.find('form table tbody').append @newSelectRow()

    @modal.on 'hide', @cleanup
            
  @genRowFunction: (inRowFunction)->
    func = null
    try
      func = new Function('try{ return ' + inRowFunction + ' }catch(err){ console.log(err); }')
    catch err
      throw err
    func
