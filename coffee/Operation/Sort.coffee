Operation.Sort = class Sort
  constructor: (@sheet)->
    @sheet['Sort.asc'] = @asc
    @sheet['Sort.desc'] = @desc
    
  exec: ()=>
  asc: (ev, args)=>
    data = @sheet.grid.getData()
    data.sort (r1, r2) ->
      return r1[args.column.field] - r2[args.column.field]
    @sheet.grid.invalidate()
    @sheet.grid.render()
  desc: (ev, args)=>
    data = @sheet.grid.getData()
    data.sort (r1, r2) ->
      return r2[args.column.field] - r1[args.column.field]
    @sheet.grid.invalidate()
    @sheet.grid.render()
