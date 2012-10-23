class Parser
  @jsonNumToInferColumns: 100
  @getParser: (type)->
    type = type.toLowerCase()
    if type is 'text/csv'
      return new CSVParser()
    else if type is 'text/json'
      return new JSONarser()
    else if type is 'text/tsv'
      return new TSVParser()
  @getHeader: (jsonArray, jsonNumToInferColumns)->
    header = {}
    for json in jsonArray.slice(0, jsonNumToInferColumns)
      for field of json
        header[field] = true
    return (key for key of header)

class JSONParser extends Parser
  parse: (datastr)->
    try
      @lines = JSON.parse(datastr)
      @Parser.getHeader(@lines, Parser.jsonNumToInferColumns)
    catch err
      console.error err
      
class TSVParser extends Parser
  parse: (datastr)->
    lines = datastr.split(/\r?\n/)
    header = lines.shift().split(/\t/)
    hLen = header.length
      
    lines = lines.map (line, __id__)->
      fields = line.split(/\t/)
      if hLen isnt fields.length
        return console.warn line
      obj = {}
      for field, idx in header
        obj[field] = fields[idx]
      obj['__id__'] = __id__
      return obj
    @header = header
    @lines = lines.filter (line)-> return line
      
class CSVParser extends Parser
  parse: (datastr)->
    lines = datastr.split(/\r?\n/)
    header = lines.shift().split(/,/)
    hLen = header.length
      
    lines = lines.map (line, __id__)->
      fields = line.split(/,/)
      if hLen isnt fields.length
        console.warn 'ヘッダサイズ('+hLen+')とデータサイズ('+fields.length+')が異なっています', line
        return false
      obj = {}
      for field, idx in header
        obj[field] = fields[idx]
      obj['__id__'] = __id__
      return obj
    @header = header
    @lines = lines.filter (line)-> return line
  