
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
            contentId: 'https://r1---sn-p5qs7ned.googlevideo.com/videoplayback?expire=1625952790&ei=tr3pYODEAsyt8wTT4amgBQ&ip=2601%3A547%3A0%3Adc40%3Ac15f%3Ad977%3A65cf%3A9c24&id=o-ABYWjQhGWADdcv-xKGJ3_T2dRGKV0caL-57IdtJB0MXq&itag=18&source=youtube&requiressl=yes&mh=Fk&mm=31%2C26&mn=sn-p5qs7ned%2Csn-ab5l6n6s&ms=au%2Conr&mv=m&mvi=1&pl=36&gcr=us&initcwndbps=2040000&vprv=1&mime=video%2Fmp4&ns=oggJrnAVRk5fMlTyZQB8pvAG&gir=yes&clen=2247377&ratebypass=yes&dur=37.523&lmt=1577548326001795&mt=1625930937&fvip=1&fexp=24001373%2C24007246&c=WEB&txp=5431432&n=qHMXcNi2pbF_CaLBDq&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cgcr%2Cvprv%2Cmime%2Cns%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRgIhAJ6jZAUOR6yHjews3dOep55Gay2ydG5tZ7SXU_R8eztbAiEAwL7qg4H9rV3AFhDp6VIZmvqX4c2_viaC6_QJsKRFjnY%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRgIhAK6gDaKRFJP8SFRJqrRwjjHl5jOMuQ9j0sIkV3YND8wYAiEA9R103ISpZjxXGQGvunZbyKKn2FkwGZCCUsKA1frK3H0%3D',
            contentType: 'video/mp4',
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
