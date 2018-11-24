const { NodeMediaServer, NodeMediaCluster } = require('node-media-server');
const numCPUs = require('os').cpus().length;

const config = {
  rtmp: {
    port: 1935,
    chunk_size: 6000,
    gop_cache: false,
    ping: 30,
    ping_timeout: 20
  },
  http: {
    port: 8000,
    allow_origin: '*'
  },
  cluster: {
    num: numCPUs
  }
};
 
exports.start = function() {
  var nmcs = new NodeMediaCluster(config)
  nmcs.run();
}