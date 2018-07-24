const WebSocket = require('ws');

exports.start = (startStream, endStream) => {

  const ws = new WebSocket('ws://localhost:5000', {
    origin: 'http://localhost:5000',
    headers: {
      'XDevice': 'RaspberryPi'
    }
  });
  
  ws.on('open', function open() {
    console.log('connected');
    ws.send(Date.now());
  });
  
  ws.on('close', function close() {
    console.log('disconnected');
  });
  
  ws.on('message', function incoming(data) {
    console.log(data);
    switch (data) {
      case "start-stream":
        startStream();
      break;
      case "end-stream":
        endStream();
        break;
    
      default:
        break;
    }
  });
};