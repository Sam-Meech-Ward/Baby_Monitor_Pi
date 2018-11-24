const { spawn } = require('child_process');
const path = require('path');


module.exports.ledOff = function() {
  const echo = spawn('echo', ['0']);
  const filePath = "/sys/class/leds/led0/brightness"; 
  // const filePath = path.join(__dirname, 'tmp.txt');
  const write1 = spawn('tee', [filePath]);
  echo.stdout.pipe(write1.stdin);
  const write2 = spawn('tee', [filePath]);
  echo.stdout.pipe(write2.stdin);
};