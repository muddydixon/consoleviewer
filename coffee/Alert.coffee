class Alert
  constructor: (target, @opts)->
    if not (typeof target is 'string' or target instanceof $)
      @opts = target
      target = undefined
    @target = $(target or '.alerts')
    if @opts?.replaceConsole?
      console.info = (console.log = @info)
      console.warn = @warn
      console.error = @error
      console.debug = @debug
      
  _template: '<div class="hide alert"><button type="button" class="close" data-dismiss="alert">x</button><h4></h4><p></p></div>'
  log: (msg, head, level)->
    body = $(@_template).clone()
    if head?
      body.find('h4').text(head)
    body.find('p').text(msg)
    body.addClass 'alert-'+level

    body.appendTo @target
    body.fadeIn(500)
    setTimeout(()=>
        body.slideUp 500, ()=>
          body.remove()
      3000
    )
      
    
  info: (msg, head)=>     # .alert-info by bootstrap
    @log(msg, head, 'info')
  warn: (msg, head)=>     # .alert-block  
    @log(msg, head, 'warn')
  error: (msg, head)=>    # .alert-error
    @log(msg, head, 'error')
  success: (msg, head)=>  # .alert-success
    @log(msg, head, 'success')
  debug: (msg, head)=>  # .alert-success
    if typeof msg is 'object'
      msg = JSON.stringify msg
    @log(msg, ['DEBUG', head].join(' '), '')
    
if module?
  module.exports = Alert