
## CLI

    cat foo.png | png-guts --strip-text > foo-normalized.png


## Library

    {PNG_FILE_HEADER, ChunkReader} = require 'png-guts'

    process.stdout.write PNG_FILE_HEADER
    reader = new ChunkReader process.openStdin()
    reader.on 'chunk', (type, raw) ->
      process.stderr.write "#{type} #{raw.length}\n"
      process.stdout.write raw
