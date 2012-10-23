formatter = (str)->
  return ()->
    args = [].slice.apply arguments
    
    return str.replace /%0?(\d+)?([ds])/g, (a, fill, t)->
      val = ''+(if t is 'd' then Number(args.shift()) else String(args.shift()))
      while fill - val.length > 0
        val = '0'+val
      return val
        
