const ws = require('./wsClient');
const stream = require('./stream');

ws.start(stream.startStream, stream.stopStream);