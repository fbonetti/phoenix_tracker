import { values, template } from 'lodash';

// Set up our Elm App
const elmApp = Elm.App.fullscreen();

const createMap = function() {
  let mapobj = new google.maps.Map(document.getElementById('map'), {
    center: {lat: 39.3431, lng: -99.3082},
    zoom: 4
  });
  return mapobj;
};

let map;
let markers = {};
let markerPath;
let infoWindow;

elmApp.ports.outgoingLocations.subscribe(function(locations) {
  map = map || createMap();

  values(markers).forEach(marker => {
    marker.setMap(null);
  });

  if (markerPath) {
    markerPath.setMap(null);
  }

  const bounds = new google.maps.LatLngBounds();
  const pathCoordinates = [];

  locations.forEach(location => {
    const marker = new google.maps.Marker({
      position: {
        lat: location.latitude,
        lng: location.longitude
      },
      map: map
    });

    marker.addListener('click', openInfoWindow.bind(this, location));

    bounds.extend(marker.getPosition());
    pathCoordinates.push({ lat: location.latitude, lng: location.longitude });
    markers[location.id] = marker;
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
  map.panTo({ lat: location.latitude, lng: location.longitude });
  openInfoWindow(location);
});

const openInfoWindow = function(location) {
  map = map || createMap();

  if (infoWindow) {
    infoWindow.close();
  }

  const infoTemplate = template(`
    <div><strong>Location info</strong></div>
    <div>Coordinates: <%- latitude %>, <%- longitude %></div>
    <div>Timestamp: <%- (new Date(recordedAt * 1000)) %></div>
    <div>Battery state: <%- batteryState %></div>
    </br>
    <div><strong>Weather data</strong></div>
    <div>Temperature: <%- temperature || "N/A" %>°F</div>
    <div>Humidity: <%- humidity ? (humidity * 100).toFixed() : "N/A" %>%</div>
    <div>Visibility: <%- visibility || "N/A" %> mi</div>
    <div>
      Wind bearing: <%- windBearing || "N/A" %>°
      <i class="wi wi-wind from-<%= Math.round(windBearing) %>-deg"></i>
    </div>
    <div>Wind speed: <%- windSpeed || "N/A" %> mph</div>
  `);

  infoWindow = new google.maps.InfoWindow({
    content: infoTemplate(location)
  });

  infoWindow.open(map, markers[location.id]);
};
