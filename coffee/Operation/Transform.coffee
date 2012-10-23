Operation.Transform = class Transform
  constructor: (sheet)->
  exec: ()=>
    @FormType.cross(@sheet)
    
    @modal.modal('hide')
    return false
  createCrossTable: (records)=>
      
  bootup: (@sheet)->
    @modal = Transform.modal

    columns = @sheet.grid.getColumns()
    for column in columns
      @modal.find('select#crossby').append $('<option>', {value: column.field}).text(column.field)
      @modal.find('select#crossvalue').append $('<option>', {value: column.field}).text(column.field)
    @modal.find('select#crossby').chosen()
    @modal.find('select#crossvalue').chosen()

    for func of Operation.Group.GroupByFunction
      @modal.find('select#crosscellfunc').append $('<option>', {value: func}).text(func)
    @modal.find('select#crosscellfunc').chosen()
    
    @modal.find('.modal-footer .exec').one 'click', @exec
    
  @cleanup: ()=>
    @modal.find('.modal-footer .exec').off 'click'

  FormType:
    cross: (@sheet)=>
      begin = new Date()
    
      selected = @modal.find('select#crossby').val()
      crossvalue = @modal.find('select#crossvalue').val()
      cellFunc = @modal.find('select#crosscellfunc').val()
  
      if selected.length > 2
        console.debug 'sorry now we cannot apply more than two fields'
        return false

      Group = Operation.Group
      @sheet.dataView.groupBy(
        (row)->
          idx = (row[field] for field in selected).join(Group.delimiter)
        (group)->
          groupByElms = group.value.split(Group.delimiter)
  
          if selected.length isnt groupByElms.length
            console.log 'fields length does not match ' + fields.join(': ') + ', ' + groupByElms.join(': ')
            return false
          
          obj = {}
          # groupByElms
          for field, idx in selected
            obj[field] = groupByElms[idx]
          obj['val'] = Group.GroupByFunction[cellFunc](group.rows, crossvalue)

          obj
        {
          sort: (a, b)->
            a.value - b.value
          end: (groups)=>
            spent = (new Date() - begin) / 1000
  
            data = []
            obj = {}
            for group in groups
              aobj = obj[group[selected[0]]]
              if not aobj?
                obj[group[selected[0]]] = {}
                obj[group[selected[0]]][selected.join '/'] = group[selected[0]]
                aobj = obj[group[selected[0]]]
              aobj[group[selected[1]]] = group.val
  
            for key, dat of obj
              data.push dat

            header = Parser.getHeader(data, 10)
            columns = Sheet.createColumns(header)
            opts = 
              rowHeight: 18
              editable: false
              enableAddRow: false
              enableCellNavigation: false
              name: selected.join('-') + '(time spent: ' + spent + ' sec)'
            sheet = new Sheet($('#sheets'), columns, opts)
            sheet.addItems data, selected.join '/'
            @modal.modal('hide')
        }
      )
    
    stack: null
    transform: null

  @init: (@modal)->
    @modal = $(@modal)
    @modal.on 'hide', @cleanup
