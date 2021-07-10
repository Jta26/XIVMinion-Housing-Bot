
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
            contentId: 'https://free-real-estate.s3.us-west-2.amazonaws.com/freerealestate.mp3?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEMj%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJGMEQCIFR3yswZgYQfmT73%2FqwXYERxtDptcC42g%2F9P%2BQ%2FevE99AiBcw32IqcMPX%2B94DG4QzEmxStiIgxOSnP1IDlSfOd029yr%2FAgix%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAMaDDkwMDg0MTk5MDQ3OSIMMxytekXFIgNbKhOKKtMCtgUGIGg06MwE2espHH3PhTOhyCSMGSBFHwMjPK3ZpXXcnTT5omHwtfjSsue0vpDs7spLjv%2Bp8EgOTGp%2B6b4b1IwRfvjS1VgCOaraHScVrXUpv0lTx2HaA5HCEgJE%2BuLNcY2Kw5%2B36ez4CUgaAs0BsFvjT%2BDMWIELoF1MlIR%2B4DGxZiQuiyaptgZkI%2FhJ82N3y6mVAaz15PDmgSGMStWY2Xk%2FmBDExk9Ulwuh53kUADBpC1LV2GYKqf4J6iRJPBoXW9ZJpwV926fNsh0%2BLk1pos1LQKzqG1CmGcxza679SnBp3j%2FLSZ3q7QsiIkO%2Fh5eErB7S4RmBXr83dfVRwe%2BlczeKwFKTZO8%2BIzR430ZL51Vs3XaLI6XQLFezKFxNySlOwmGmDfMFAyQU%2B51OvOLY5jAU938svUUjAXC%2BAsHkIdkHInPOXhDkYKuzOZ%2F2KNF01zgYMJDZqIcGOrQCI4r73Ai39dbbz19PvfGUJB8WM4%2FvT3vneV4cxJ%2FifW2n9Js2oN2bmsc7d4Vwi%2BLP1YUpgOBqAlmXBNnq6IjbN98UnB%2BcRdYZptU4RLNKEuxqplXktnx3%2FxIysyst%2ByHK7I8kzDrzoDdsicHRSNfvfV4lPDQhfcnJIiqUn5zDc%2B3SAMnzZ0jG5eff%2B3O%2BcFATz8fxsawXq7fhduB3zDcrItYS8u45hy6SCVUNXnWL79IOn%2BkqpOJjiberWc51%2F5pvAyM%2B%2Bpkr158hWO%2FzX4dmrzG2gfo9xAJ6fL4D41FSygc5J1r4yC%2FK%2BeqL2ZoFno3bAa3iry%2BlCU3D9rfjbVftAIMyqD3QoWpHEOevH%2B2SWpwoamSOu456Pm700c%2FBKJWqThNJ83DWC1u%2FyLxOSWGOvB6lGJ8%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20210710T234130Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIA5DPS55FHWTU7QABX%2F20210710%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=c31d428f106ba5f95aec943733b6877a13e9a17ed48eb753d2f4b879b5de2ad5',
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
