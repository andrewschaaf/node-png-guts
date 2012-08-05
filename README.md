
## Command-line tool

    cat foo.png | png-guts --strip-ancillary > foo-normalized.png

Options:

    --strip-test            strip {iTXt,tEXt,zTXt} chunks
    --strip-ancillary       strip all chunks other than {IHDR,PLTE,IDAT,IEND}


## NodeJS library example

    {PNG_FILE_HEADER, PNGChunkReader} = require 'png-guts'

    inspect_png = (readable_stream) ->
      size = PNG_FILE_HEADER.length
      reader = new PNGChunkReader readable_stream
      reader.on 'chunk', (type, data) ->
        console.log "#{type} chunk: #{data.length} bytes"
        size += data.length
      reader.on 'end', () ->
        console.log "file size: #{size.length} bytes"


## What is a PNG?

Every PNG file consists of `89 50 4E 47 0D 0A 1A 0A` followed by chunks.

Every chunk is encoded thusly:

<pre>
4 bytes     data length: N as a big-endian unsigned 32-bit integer
4 bytes     chunk type: usually ASCII
N bytes     ...data...
4 bytes     <a href="https://en.wikipedia.org/wiki/Cyclic_redundancy_check">CRC</a>
</pre>

These are four critical chunk types:

<pre>
<a href="http://www.w3.org/TR/PNG/#11IHDR">IHDR</a>: the first chunk, with metadata

<a href="http://www.w3.org/TR/PNG/#11PLTE">PLTE</a>: a color palette

<a href="http://www.w3.org/TR/PNG/#11IDAT">IDAT</a>: image data

<a href="http://www.w3.org/TR/PNG/#11IEND">IEND</a>: the last chunk
</pre>

Further reading:

- [Wikipedia: PNG](https://en.wikipedia.org/wiki/Portable_Network_Graphics)
- [Portable Network Graphics (PNG) Specification (Second Edition)](http://www.w3.org/TR/PNG/)