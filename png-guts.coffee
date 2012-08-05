{EventEmitter} = require 'events'
{readData} = require 'tafa-misc-util'


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
  reader = new PNGChunkReader process.openStdin()
  reader.on 'chunk', (type, raw) ->
    return if typeWhitelist and not (typeWhitelist[type]?)
    return if typeBlacklist[type]?
    process.stdout.write raw


class PNGChunkReader extends EventEmitter
  constructor: (stream) ->
    super()
    readData stream, (data) =>
      pos = 8
      while pos < data.length
        size = read_uint32be data, pos
        totalChunkSize = 4 + 4 + size + 4
        type = data.slice(pos + 4, pos + 8).toString('utf-8')
        raw = data.slice pos, (pos + totalChunkSize)
        @emit 'chunk', type, raw
        pos += totalChunkSize
      @emit 'end'


read_uint32be = (buf, pos) ->
  (
    (buf[pos + 0] << 24) +
    (buf[pos + 1] << 16) +
    (buf[pos + 2] << 8) +
    (buf[pos + 3]))


uint32be = (n) ->
  new Buffer [
    (n >> 24) % 256,
    (n >> 16) % 256,
    (n >> 8) % 256,
    (n) % 256
  ]


module.exports = {main, PNGChunkReader, PNG_FILE_HEADER}
if not module.parent
  main()
