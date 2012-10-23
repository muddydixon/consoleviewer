Operation.Group = class Group
  constructor: ()->
  exec: ()=>
    begin = new Date()
    # group by elements
    fields = @modal.find('.modal-body select').val()
    selects = []
    for row in @modal.find('.modal-body table tbody tr')
      select = []
      $(row).find('input').each (idx, input)->
        select.push $(input).val()
      select.push $(row).find('select').val()
      selects.push select
    
    @dataView.groupBy(
      (row)->
        idx = (row[field] for field in fields).join(Group.delimiter)
      (group)->
        groupByElms = group.value.split(Group.delimiter)

        if fields.length isnt groupByElms.length
          console.log 'fields length does not match ' + fields.join(': ') + ', ' + groupByElms.join(': ')
          return
          
        obj = {}
        # groupByElms
        for field, idx in fields
          obj[field] = groupByElms[idx]
        for select, idx in selects
          obj[select[0]] = Group.GroupByFunction[select[2]](group.rows, select[1])
        obj
      {
        sort: (a, b)->
          a.value - b.value
        end: (groups)=>
          spent = (new Date() - begin) / 1000
          header = Parser.getHeader(groups, 10)
          columns = Sheet.createColumns(header)
          group[Sheet.dataViewId] = idx for group, idx in groups 
          opts = 
            rowHeight: 18
            editable: false
            enableAddRow: false
            enableCellNavigation: false
            name: fields + '(time spent: ' + spent + ' sec)'
          sheet = new Sheet($('#sheets'), columns, opts)
          sheet.addItems groups
          @modal.modal('hide')
      }
    )

  @GroupByFunction:
    # see http://dev.mysql.com/doc/refman/5.1/ja/group-by-functions.html
    bit_and: (rows, inRowFunc)->
      rowFunc = Group.genRowFunction(inRowFunc)
      for row in rows
        val = rowFunc.call(row)
        if not val?
          return false
      true
      
    bit_or: (rows, inRowFunc)->
      rowFunc = Group.genRowFunction(inRowFunc)
      for row in rows
        val = rowFunc.call(row)
        if val?
          return true
      false
#     bit_xor: null
      
    count: (rows, inRowFunc)->
      rows.length
      
    group_concat: (rows, inRowFunc)->
      str = ''
      rowFunc = Group.genRowFunction(inRowFunc)
      for row in rows
        str += ""+rowFunc.call(row)
      str
      
    ave: (rows, inRowFunc)->
      sum = 0
      rowFunc = Group.genRowFunction(inRowFunc)
      for row in rows
        val = Number(rowFunc.call(row))
        if val?
          sum += val
      sum / rows.length
    
    min: (rows, inRowFunc)->
      min = Infinity
      rowFunc = Group.genRowFunction(inRowFunc)
      for row in rows
        val = Number(rowFunc.call(row))
        if val?
          min = if min < val then min else val
      min
      
    max: (rows, inRowFunc)->
      max = -Infinity
      rowFunc = Group.genRowFunction(inRowFunc)
      for row in rows
        val = Number(rowFunc.call(row))
        if val?
          max = if max > val then max else val
      max

#     std: null
#     stdev: null
#     stdev_pop: null
#     stdev_samp: null
    sum: (rows, inRowFunc)->
      sum = 0
      rowFunc = Group.genRowFunction(inRowFunc)
      for row in rows
        val = Number(rowFunc.call(row))
        if val?
          sum += val
      sum
      
    product: (rows, inRowFunc)->
      prod = 1
      rowFunc = Group.genRowFunction(inRowFunc)
      for row in rows
        val = Number(rowFunc.call(row))
        if val?
          prod *= val
      prod
#     var_pop: null
#     var_samp: null
#     variance: null
      
  @delimiter: '__$__'
  bootup: (sheet)=>
    @modal = Group.modal
    @columns = sheet.grid.getColumns()
    @dataView = sheet.dataView
    
    # append default value

    for column in @columns
      @modal.find('select#groupby').append $('<option>', {value: column.field}).text(column.field)
    @modal.find('select#groupby').chosen()

    @modal.find('.modal-footer .exec').one 'click', @exec

    @modal.find('form select#groupby').chosen()
    @modal.find('form table tbody').append Group.newSelectRow()

  @cleanup: ()=>
    # chzn clean
    @modal.find('form select#groupby option').remove()
    @modal.find('form select#groupby').val('')
    @modal.find('form select#groupby').removeClass 'chzn-done'
    @modal.find('form select#groupby').next().remove()
    
    # groupfield clean
    @modal.find('form table tbody tr').remove()
    @modal.find('.modal-footer .exec').off 'click'
    
  @newSelectRow: ()->
    $tr = $('<tr>', {class: 'groupOutput'})
    $tr.append $('<td>').append $('<input>', {type: 'input', class: 'input-small', name: 'key'})
    $select = $('<select>', {name: 'groupbyfunction'})
    $tr.append $('<td>').append $select.append.apply($select, ($('<option>').text(funcname) for funcname of Group.GroupByFunction ) )
    $tr.append $('<td>').append $('<input>', {type: 'input', class: 'input', name: 'inrowfunction'})
    $tr.append $('<td>').append $('<a>', {class: 'close'}).html('&times;')
    return $tr
    
  @genRowFunction: (inRowFunction)->
    new Function('try{ return ' + inRowFunction + ' }catch(err){ console.log(err); }')
  
            
  @init: (@modal)->
    @modal = $(@modal)
    
    @modal.find('form .addValue').on 'click', ()=>
      @modal.find('form table tbody').append @newSelectRow()

    @modal.on 'hide', @cleanup

  