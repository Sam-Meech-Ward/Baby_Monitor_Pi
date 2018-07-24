const shell = require('shelljs');

function startStream() {
  shell.exec('./start-pi-camera-secure.sh -lc')
}
exports.startStream = startStream;

function stopStream() {
  shell.exec('./start-pi-camera-secure.sh')
}
exports.stopStream = stopStream;