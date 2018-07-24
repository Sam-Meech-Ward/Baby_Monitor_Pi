const shell = require('shelljs');

function startStream() {
  shell.exec('./start-pi-camera-secure.sh -lc &', {silent});
}
exports.startStream = startStream;

function stopStream() {
  shell.exec('./start-pi-camera-secure.sh &', {silent})
}
exports.stopStream = stopStream;