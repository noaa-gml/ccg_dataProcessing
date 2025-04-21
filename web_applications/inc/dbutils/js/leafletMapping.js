//Functions to support leaflet mapping lib

// specify a global variable map that can be used in the functions
var map = "";


//--------------------------------------------------------------
function lm_makeMap(divID,lat=0.0, lng=0.0, zoom=1) {

	mqMap = L.esri.basemapLayer('Streets');
 	landMap = L.esri.basemapLayer('Imagery');
 	topoMap = L.esri.basemapLayer('Topographic');
	geoMap = L.esri.basemapLayer('NationalGeographic');

	map = L.map(divID, {
		layers: [mqMap],
		worldCopyJump: true,
		zoomControl: true,
		"tap": false
	});

	var baseLayers = {
		"Map": mqMap,
		"Satellite": landMap,
		"Topographic": topoMap,
		"Geographic": geoMap,
	};

	L.control.layers(baseLayers).addTo(map);
	map.setView([lat, lng], zoom);
}
//--------------------------------------------------------------
//// A function to create the marker and tooltip
function lm_createMarker(lat, lng, tooltip, color="#ff0000",onClick=NULL) {

        radius = 5;
        //if (L.Browser.retina) { radius = 10; }
        //color = "#ff0000";

        marker = L.circleMarker([lat, lng], {
                radius: radius,
                fillColor: color,
                color: "#000",
                weight: 1,
                opacity: 1,
                fillOpacity: 0.8,
        }).addTo(map).bindTooltip(tooltip).on('click',onClick);
       return marker;
}
function lm_createMarker2(lat, lng, tooltip, color="#ff0000",onClick=NULL,radius,shape) {

        radius = 5;
        //if (L.Browser.retina) { radius = 10; }
        //color = "#ff0000";

        marker = L.circleMarker([lat, lng], {
                radius: radius,
                fillColor: color,
                color: "#000",
                weight: 1,
                opacity: 1,
                fillOpacity: 0.8,
        }).addTo(map).bindTooltip(tooltip).on('click',onClick);
       return marker;
}


 
