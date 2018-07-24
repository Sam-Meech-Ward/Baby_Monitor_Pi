const shell = require('shelljs');

function startStream() {
  shell.exec('./start-pi-camera-secure.sh -lc -i 138.197.151.166 &', {silent: true, async: true});
}
exports.startStream = startStream;

function stopStream() {
  shell.exec('./start-pi-camera-secure.sh &', {silent: true, async: true})
}
exports.stopStream = stopStream;