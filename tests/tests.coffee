fs = require 'fs'
{exec} = require 'child_process'
assert = require 'assert'
async = require 'async'
{PNGChunkReader, BIN_PATH} = require '../png-guts'


main = () ->
  async.series [
    ((c) -> test_chunks 'line-iCCP', c)
    ((c) -> test_chunks 'line-sRGB-tEXt', c)
    ((c) -> test_stripping 'line-sRGB-tEXt', 'nothing', c)
    ((c) -> test_stripping 'line-sRGB-tEXt', 'text', c)
    ((c) -> test_stripping 'line-sRGB-tEXt', 'ancillary', c)
  ], (e) ->
    throw e if e
    console.log 'OK'


test_stripping = (name, type, c) ->
  tmp = "#{__dirname}/temp"
  exec "mkdir -p '#{tmp}'", (e) ->
    return c e if e
    src = "#{__dirname}/pngs/#{name}.png"
    dest = "#{tmp}/#{name}-strip-#{type}.png"
    exec "cat '#{src}' | '#{BIN_PATH}' --strip-#{type} > '#{dest}'", (e) ->
      return c e if e
      result_hex = fs.readFileSync(dest).toString 'hex'
      expected_hex = fs.readFileSync("#{__dirname}/pngs/#{name}-strip-#{type}.png").toString 'hex'
      assert.equal result_hex, expected_hex
      c null


test_chunks = (name, c) ->
  chunks_of name, (chunks) ->
    assert.equal JSON.stringify(chunks), fs.readFileSync("#{__dirname}/pngs/#{name}.json")
    c null


chunks_of = (name, c) ->
  arr = []
  stream = fs.createReadStream "#{__dirname}/pngs/#{name}.png"
  reader = new PNGChunkReader stream
  reader.on 'chunk', (type, data) ->
    arr.push [type, data.toString('hex')]
  reader.on 'end', () ->
    c arr


module.exports = {main}
if not module.parent
  main()
