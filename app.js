const server = require('./server');
const pi = require('./pi');
const camera = require('./camera');

const rmtmpURL = process.argv[2] || 'rtmp://localhost/myapp/pi';

(async function() {
  pi.ledOff();
  await server.start();
  camera.start(rmtmpURL);
})();

