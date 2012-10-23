# load parent setting
server = module.parent.exports

# load modules
crypto = require 'crypto'
io = require('socket.io').listen server

# listen websocket


md5 = (str) ->
  md5sum = crypto.createHash 'md5'
  md5sum.update str
  md5sum.digest "hex"

############################################################
#
class Room
  constructor: (@key)->
    if not @key?
      @key = md5((0 | Math.random() * 10000) + new Date())

    @socketList = {}

    @sockets = io.of("/#{@key}")
    
    @sockets.on 'connection', @onConnect
    console.log "create room (#{@key})"
    
  onConnect: (socket)=>
    console.log "connection to this room (#{@key})"
    
#     @socketList[socket.id] = socket
    socket.join @key
    socket.on 'data', @onData
    socket.on 'sheet', @onSheet
    socket.on 'disconnect', @onDisconnect
    
  onData: (data)->
    console.log data
#     this.broadcast.emit 'data', data
    io.sockets.in(@key).emit 'data', data
    
  onSheet: (data)->
    console.log data
#     this.broadcast.emit 'sheet', data
    io.sockets.in(@key).emit 'sheet', data
    
  onDisconnect: ()->
    socket.leave @key
      
      
############################################################
# rooms
rooms = {}

# socket main
io.sockets.on 'connection', (socket) ->
  socket.on 'disconnect', ->
    console.log 'disconnect'
  socket.on 'room', (data) ->
    # create
    if data.cmd is 'create'
      room = new Room()
      if rooms[room.key]?
        throw new Error 'key duplicated'
      rooms[room.key] = room 
      
      socket.emit 'room',
        status: 200
        key: room.key

    else if data.cmd is 'enter'
      if rooms[data.key]?
        socket.emit 'room',
          status: 200
          key: data.key
      else
        socket.emit 'room',
          status: 404
          err:
            msg: "no room for key #{data.key}"
          
  socket.emit 'ack', {'status': 200}
