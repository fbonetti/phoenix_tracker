// Set up our Elm App
const elmDiv = document.querySelector('#elm-container');
const elmApp = Elm.App.embed(elmDiv);

const createMap = function() {
  return new google.maps.Map(document.getElementById('map'), {
    center: {lat: 41.8781, lng: -87.6298},
    zoom: 6
  });
};

let map;
let markers = [];

elmApp.ports.outgoingLocations.subscribe(function(locations) {
  map = map || createMap();

  markers.forEach(marker => {
    marker.setMap(null);
  });

  markers = locations.map(location => {
    return new google.maps.Marker({
      position: {
        lat: location.latitude,
        lng: location.longitude
      },
      map: map
    });
  });
});
