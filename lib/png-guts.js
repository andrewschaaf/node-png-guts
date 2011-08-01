(function() {
  var ChunkReader, EventEmitter, PNG_FILE_HEADER, main, readData, read_uint32be, uint32be;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  EventEmitter = require('events').EventEmitter;
  readData = require('tafa-misc-util').readData;
  PNG_FILE_HEADER = new Buffer([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  main = function() {
    var argv, ignoreBlocks, k, reader, _i, _len, _ref;
    argv = require('optimist').argv;
    ignoreBlocks = {};
    if (argv['strip-text']) {
      _ref = ['iTXt', 'tEXt', 'zTXt'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        k = _ref[_i];
        ignoreBlocks[k] = true;
      }
    }
    process.stdout.write(PNG_FILE_HEADER);
    reader = new ChunkReader(process.openStdin());
    return reader.on('chunk', function(type, raw) {
      if (!ignoreBlocks[type]) {
        return process.stdout.write(raw);
      }
    });
  };
  ChunkReader = (function() {
    __extends(ChunkReader, EventEmitter);
    function ChunkReader(stream) {
      ChunkReader.__super__.constructor.call(this);
      readData(stream, __bind(function(data) {
        var pos, raw, size, totalChunkSize, type, _results;
        pos = 8;
        _results = [];
        while (pos < data.length) {
          size = read_uint32be(data, pos);
          totalChunkSize = 4 + 4 + size + 4;
          type = data.slice(pos + 4, pos + 8).toString('utf-8');
          raw = data.slice(pos, pos + totalChunkSize);
          this.emit('chunk', type, raw);
          _results.push(pos += totalChunkSize);
        }
        return _results;
      }, this));
    }
    return ChunkReader;
  })();
  read_uint32be = function(buf, pos) {
    return (buf[pos + 0] << 24) + (buf[pos + 1] << 16) + (buf[pos + 2] << 8) + buf[pos + 3];
  };
  uint32be = function(n) {
    return new Buffer([(n >> 24) % 256, (n >> 16) % 256, (n >> 8) % 256, n % 256]);
  };
  if (!module.parent) {
    main();
  }
  module.exports = {
    main: main,
    ChunkReader: ChunkReader
  };
}).call(this);
