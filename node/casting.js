
var Client = require('castv2-client').Client;
var DefaultMediaReceiver = require('castv2-client').DefaultMediaReceiver;
const mdns = require('mdns');

var browser = mdns.createBrowser(mdns.tcp('googlecast'));

browser.on('serviceUp', function(service) {
  console.log('found device "%s" at %s:%d', service.name, service.addresses[0], service.port);
  // ondeviceup(service.addresses[0]);
  if (service.name.includes('Google-Home')) {
    ondeviceup(service.addresses[0]);
  }
  browser.stop();
});

browser.start();


function ondeviceup(host) {
  let client = new Client();
  client.connect(host, function() {
      console.log('conncted to google home.');
  
      client.launch(DefaultMediaReceiver, function(err, player) {
          var media = {
  
            // Here you can plug an URL to any mp4, webm, mp3 or jpg file with the proper contentType.
            contentId: 'https://free-real-estate.s3.us-west-2.amazonaws.com/freerealestate.mp3',
            contentType: 'audio/mpeg',
            streamType: 'BUFFERED', // or LIVE
            // Title and cover displayed while buffering
            metadata: {
              type: 0,
              metadataType: 0,
              title: `${process.argv[2]}`, 
              images: [
                { url: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg' }
              ]
            }        
          };
  
          player.on('status', function(status) {
              console.log('Status Broadcasting state=%s', status.playerState);
          });
  
          console.log('app "%s" launched, loading media %s ...', player.session.displayName, media.contentId);
  
          player.load(media, { autoplay: true }, function(err, status) {
              if (err) {
                  console.error(err);
              }
              else {
                  if (status.playerState == "PLAYING") {
                      process.exit(1)
                  }
                  console.log('media loaded playerState=%s', status.playerState);
              } 
            });
      });
  
      client.on('error', function(err) {
          console.log('Error: %s', err.message);
          client.close();
        });
  });  
}
