
## Command-line tool

    cat foo.png | png-guts --strip-text > foo-normalized.png


## NodeJS library example

    {PNG_FILE_HEADER, ChunkReader} = require 'png-guts'

    inspect_png = (readable_stream) ->
      size = PNG_FILE_HEADER.length
      reader = new ChunkReader readable_stream
      reader.on 'chunk', (type, data) ->
        console.log "#{type} chunk: #{data.length} bytes"
        size += data.length
      reader.on 'end', () ->
        console.log "file size: #{size.length} bytes"
