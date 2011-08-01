
{EventEmitter} = require 'events'
{readData} = require 'tafa-misc-util'


PNG_FILE_HEADER = new Buffer [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]


main = () ->
  
  argv = require('optimist').argv
  
  # --strip-text
  ignoreBlocks = {}
  if argv['strip-text']
    for k in ['iTXt', 'tEXt', 'zTXt']
      ignoreBlocks[k] = true
  
  process.stdout.write PNG_FILE_HEADER
  reader = new ChunkReader process.openStdin()
  reader.on 'chunk', (type, raw) ->
    if not ignoreBlocks[type]
      process.stdout.write raw


class ChunkReader extends EventEmitter
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


if not module.parent
  main()

module.exports =
  main: main
  ChunkReader: ChunkReader
  PNG_FILE_HEADER: PNG_FILE_HEADER
