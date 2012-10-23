# Cakefile

{exec, spawn} = require 'child_process'
cs = require 'coffee-script'

run = (args, cb) ->
  proc = spawn args.shift(), args
  proc.stderr.on 'data', (buffer) -> console.error buffer.toString()
  proc.stdout.on 'data', (buffer) -> console.log buffer.toString().replace(/\n$/, '')
  proc.on 'exit', (status)->
    process.exit(1) if status != 0
    cb() if typeof cb is 'function'

task "build", "build coffee", ->
  compile()

task "dev", "watch coffee script", ->
  compile(true)

task "publish", "build coffee", ->
  compile()
  run ['cp', 'public/js/consoleViewer.js', 'consoleViewer.js']
  
task "test", "test", ->
  test()

############################################################
#
#
buildrules =
  'public/js/consoleViewer.js': [
    '-b',
    './coffee/util.coffee'
    './coffee/Alert.coffee'
    './coffee/Socket.coffee'
    './coffee/Parser.coffee'
    './coffee/Sheet.coffee'
    './coffee/Operation.coffee'
    './coffee/Operation/Chart.coffee'
    './coffee/Operation/Sort.coffee'
    './coffee/Operation/Transform.coffee'
    './coffee/Operation/Field.coffee'
    './coffee/Operation/Group.coffee'
    './coffee/Operation/Filter.coffee'
    './coffee/index.coffee'
    ]

test = ()->
  run ['node_modules/mocha/bin/mocha', '-r', 'test.helper.js', '--compilers', 'coffee:coffee-script', '-R', 'spec']

  
############################################################
#
#
compile = (isDev, callback)->
  if typeof isDev is 'function'
    callback = isDev
    isDev = false
  for js, coffees of buildrules
    rule = ['node', './node_modules/coffee-script/bin/coffee']
    rule.push '-w' if isDev
    rule.push '-j'
    rule.push js
    rule.push '-c'
    rule = rule.concat coffees
    ((target)->
      run rule, ()->
        console.log('compile ' + target)
        callback()
      )(js)

