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
let markerPath;

elmApp.ports.outgoingLocations.subscribe(function(locations) {
  map = map || createMap();

  markers.forEach(marker => {
    marker.setMap(null);
  });

  if (markerPath) {
    markerPath.setMap(null);
  }

  const bounds = new google.maps.LatLngBounds();
  const pathCoordinates = [];

  markers = locations.map(location => {
    const marker = new google.maps.Marker({
      position: {
        lat: location.latitude,
        lng: location.longitude
      },
      map: map
    });

    bounds.extend(marker.getPosition());
    pathCoordinates.push({ lat: location.latitude, lng: location.longitude });
    return marker;
  });

  markerPath = new google.maps.Polyline({
    path: pathCoordinates,
    strokeColor: '#FF0000',
    strokeOpacity: 1.0,
    strokeWeight: 2
  });

  map.fitBounds(bounds);
  markerPath.setMap(map);
});

elmApp.ports.selectLocation.subscribe(function(location) {
  map = map || createMap();
  map.setCenter({ lat: location.latitude, lng: location.longitude });
});
