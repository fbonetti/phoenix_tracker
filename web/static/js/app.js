// Set up our Elm App
const elmDiv = document.querySelector('#elm-container');
const elmApp = Elm.App.embed(elmDiv);

const createMap = function() {
  let mapobj = new google.maps.Map(document.getElementById('map'), {
    center: {lat: 39.3431, lng: -99.3082},
    zoom: 4
  });
  return mapobj;
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
