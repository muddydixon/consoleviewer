alert = new Alert()  
YYYYMMDD = formatter("%04d-%02d-%02d")
#
# Sheet operations
#
$addSheet = $('#addSheet')
$addSheet.find('input[type=file]').on 'change', ()->
  files = this.files

  for file in files
    type = file.type
    name = file.name
    
    reader = new FileReader()
    $reader = $(reader)
    $reader.on 'load', (ev)->
      result = ev.target.result
      $addSheet.data(['file', type, name].join('__$__'), result)
    $reader.on 'progress', (ev)->
      true
      
    reader.readAsText(file, "UTF-8")
  
$addSheet.find('.modal-footer a.add').click ()->
  $addSheet.find('form').trigger 'submit'
  
$addSheet.find('form').submit ()->
  for name, datastr of $addSheet.data()
    if datastr? and name.match /^file__\$__/
      elms = name.split(/__\$__/)
      
      type = elms[1]
      filename = elms[2]

      room.sendSheet {data: datastr, type: type}
      
      parser = Parser.getParser(type)

      data = parser.parse(datastr)

      header = parser.header
      header.unshift Sheet.dataViewId


      columns = Sheet.createColumns(header)

      opts = $.extend({}, {}, {name: filename})
      sheet = new Sheet($('#sheets'), columns, opts)

      sheet.addItems data
      $addSheet.data(name, null)
  $addSheet.find('input[type=file]').val(null)
  $addSheet.modal('hide')
  return false

# だるいので期初から読み込んでおくものを用意しておく
# $.get($DATAFILE).done (datastr)->
#   parser = Parser.getParser('text/csv')

#   data = parser.parse(datastr)
#   header = parser.header
#   header.unshift Sheet.dataViewId

#   columns = Sheet.createColumns(header)

#   opts = $.extend({}, {}, {name: filename})
#   sheet = new Sheet($('#sheets'), columns, opts)
#   sheet.addItems data


#
# operations
#
Operation.Group.init('#setGroup')
Operation.Field.init('#addField')
Operation.Transform.init('#transformTable')
Operation.Chart.init('#createChart')


$('.sendbeacon').on 'click', ()->
  room.sendData 'beacon'
#
# Tag Nav operations
#
$('#sheets a').on 'click', (ev)->
  ev.preventDefault()
  $(this).tab('show')
