key = location.hash?.replace(/^\#/, '')
room = null


socket = io.connect('http://localhost')
socket.on 'ack', (data)->
  console.log 'ack', data
  if key? and key isnt ""
    socket.emit 'room', {cmd: 'enter', key: key}
  else
    socket.emit 'room', {cmd: 'create'}
  
  socket.on 'room', (res)->
    if res.err?
      return console.debug res.err
    room = new Room(res.key)
#     socket.disconnect()
# 
# 基本は初期化などにio.socketを使った後は、room namespaceにつないだ後は切断する
class Room
  constructor: (@key)->
    @socket = io.connect("http://#{location.host}/#{@key}")
    
    console.debug "get room #{@key}"
    location.hash = "##{@key}"

    @socket.on 'data', @_getData
    @socket.on 'sheet', @_getSheet
    
  sendSheet: (data)->
    console.debug 'sendSheet', data
    @socket.emit 'sheet', data
    
  _getSheet: (data)->
    alert.info('sheet recieved')
    parser = Parser.getParser(data.type)

    data = parser.parse(data.data)

    header = parser.header
    header.unshift Sheet.dataViewId

    columns = Sheet.createColumns(header)

    opts = $.extend({}, {}, {name: filename})
    sheet = new Sheet($('#sheets'), columns, opts)

    sheet.addItems data
    $addSheet.data(name, null)

  sendData: (data)->
    console.debug 'sendData', data
    @socket.emit 'data', data
  _getData: (data)->
    console.debug data
  