{EventEmitter} = require 'events'

BIN_PATH = "#{__dirname}/bin/png-guts"
PNG_FILE_HEADER = new Buffer [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]


main = () ->
  
  argv = require('optimist').argv
  
  typeWhitelist = null
  typeBlacklist = {}
  
  if argv['strip-text']?
    typeBlacklist = {'iTXt', 'tEXt', 'zTXt'}
  
  if argv['strip-ancillary']?
    typeWhitelist = {'IHDR', 'PLTE', 'IDAT', 'IEND'}
  
  process.stdout.write PNG_FILE_HEADER
  process.stdin.resume()
  reader = new PNGChunkReader process.stdin
  reader.on 'chunk', (type, raw) ->
    return if typeWhitelist and not (typeWhitelist[type]?)
    return if typeBlacklist[type]?
    process.stdout.write raw


class PNGChunkReader extends EventEmitter
  constructor: (stream) ->
    super()
    read_data stream, (data) =>
      pos = 8
      while pos < data.length
        size = data.readUInt32BE pos
        totalChunkSize = 4 + 4 + size + 4
        type = data.slice(pos + 4, pos + 8).toString('utf-8')
        raw = data.slice pos, (pos + totalChunkSize)
        @emit 'chunk', type, raw
        pos += totalChunkSize
      @emit 'end'


read_data = (stream, callback) ->
  arr = []
  stream.on 'data', (data) ->
    arr.push data
  stream.on 'end', () ->
    callback Buffer.concat arr


module.exports = {BIN_PATH, main, PNGChunkReader, PNG_FILE_HEADER}
if not module.parent
  main()
