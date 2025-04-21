<?php

#################################################################
function getSiteTabHtml ($code, $name, $country, $lat, $lon, $elev)
{

	$tab1 = "<table border=0>"
	. "<tr><td colspan=2>"
	. "<b><a href=/dv/site/site.php?code=$code>"
	. "$name, $country ($code)</a></b></td></tr>"
	. "<tr><td><b>Lat:</b></td><td>$lat</td></tr>"
	. "<tr><td><b>Lon:</b></td><td>$lon</td></tr>"
	. "<tr><td><b>Elev:</b></td><td>$elev</td></tr>"
	. "</table>";

	return $tab1;
}

#################################################################
function gMapCreate($width, $height)
{


$key = file_get_contents ('google.key');
echo "<body onunload='GUnload()'><body>\n";

echo "<script src='http://maps.google.com/maps?file=api&v=2&key=$key' type='text/javascript'></script>\n";
#echo "<script src='gxmarker.2.js' type='text/javascript'></script>\n";
echo "<script src='gzoom_uncompressed.js' type='text/javascript'></script>\n";
echo "<div id='map' style='width: ${width}px; height: ${height}px; '></div>\n";

?>
</div>
</div>
</div>
<script type="text/javascript">
	//<![CDATA[

	// Create our "tiny" marker icon
        var baseIcon = new GIcon();
        baseIcon.image = "/dv/site/pushpins/webhues/038.small.png";
//        baseIcon.shadow = "/dv/site/pushpins/templates/shadow50.small.png";
        baseIcon.iconSize = new GSize(10, 17);
//        baseIcon.shadowSize = new GSize(18, 17);
        baseIcon.iconAnchor = new GPoint(4, 17);
        baseIcon.infoWindowAnchor = new GPoint(4, 1);

	var icons=[];
	var gmarkers=[];
	var points=[];
	var map;

	// Function to turn markers on or off because of clicks on check boxes
	function Markers(color){
		map.closeInfoWindow();
		if (document.getElementById(color).checked==false) { // hide the marker
			for (var i=0;i<gmarkers.length;i++) {
				if (gmarkers[i].type==color)  {
					map.removeOverlay(gmarkers[i]);
				}
			}
		} else { // show the marker again
			for (var i=0;i<gmarkers.length;i++) {
				if (gmarkers[i].type==color)  {
					map.addOverlay(gmarkers[i]);
				}
			}
		}
	}

	// Get the marker icon to use based on project number
	function coloredRideshareIcon(iconColor) {
		var color;
		if ((typeof(iconColor)=="undefined") || (iconColor==null)) {
			color = "red"
		} else {
			color = iconColor;
		}
		if (!icons[iconColor]) {
			var icon = new GIcon(baseIcon);
			icon.image = "/dv/site/pushpins/webhues/"+color+".small.png";
			icons[iconColor]=icon;
		}
		return icons[iconColor];
	}

	// Add a marker to the map.
	function addMarker(lng, lat, iconStr, tabs, tooltip, visible) {
		var point = new GPoint(lng, lat);
		// bounds.extend(point);
		var icon = coloredRideshareIcon(iconStr);
		var marker = new GMarker(point, {title:tooltip, icon:icon});
//var marker = new GxMarker( point, icon, tooltip);
		gmarkers.push(marker);
		marker.type = iconStr;
		GEvent.addListener(marker, "click", function () {
			marker.openInfoWindowHtml(tabs);
		});
		if (visible) {
			map.addOverlay(marker);
		}
	}

	function addPolyline(iconStr, visible) {
		var marker = new GPolyline(points);
		gmarkers.push(marker);
		marker.type = iconStr;
		if (visible) {
			map.addOverlay(marker);
		}
	}

	if (GBrowserIsCompatible()) {
  
		// Create the map
		var map = new GMap2(document.getElementById("map"));
		map.addControl(new GLargeMapControl());
		map.addControl(new GMapTypeControl());
		map.setCenter(new GLatLng(0, 0), 1);
		map.addControl(new GZoomControl(),new GControlPosition(G_ANCHOR_TOP_LEFT,new GSize(80,10)));

<?php

}

#################################################################
function gMapAddPolyline ($lat, $lon)
{
#	echo "var points = [];\n";
	echo "points = [];\n";
	$n = 0;
	foreach ($lat as $y) {
		$x = $lon[$n];
		echo "points.push(new GLatLng($y, $x));\n";
		$n++;
	}
#	echo "map.addOverlay(new GPolyline(points));\n";
}


#################################################################
function gMapClose ()
{
?>
	}
	//]]>
</script>
<div id="container">
<div id="pbody">
<div id="content">
<?php

}

###################################################################
function getSiteDescription($code) {

	$i=0;
	$username="";
	$password="";
	$database="";

	mysql_connect("localhost",$username,$password) or die("Unable to make a connection to the database");
	@mysql_select_db($database) or die("Unable to select database");

	if ($code == NULL) { return ("Invalid site code."); }
	$lowcode=strtolower($code);
	$upcode=strtoupper($code);


	$query="SELECT * FROM site WHERE CODE='" . mysql_real_escape_string($code) . "'";
#echo $query;
	$result=mysql_query($query);
$nrows = 0;
if ($result) {
	$nrows = mysql_num_rows($result);
}

if (!$nrows) {
	$data = "<p>No station for code $code.";
	return $data;
}


	$r = mysql_fetch_object($result);

	$site_num = $r->num;
	$name = $r->name;
	$country = $r->country;
	$lat = $r->lat;
	$lon = $r->lon;
	$elev = $r->elev;
	$lst2utc = $r->lst2utc;
	$flag = $r->flag;
	$description = $r->description;
#	$map = $r->map;
	$map = $upcode . ".png";
	$gallery_id = $r->galleryId;

	$flagurl = "/gmd/images/flags/smallflags/$flag";

#	$query="SELECT name,url,logo FROM site_coop WHERE site_num=$site_num";
#	$result=mysql_query($query);
#	$row = mysql_fetch_row($result);
#	$coopname = $row[0];
#	$coopurl = $row[1];
#	$cooplogo = $row[2];

	$data = "<title>GMD Site Description: $code</title>\n";

	# Header, includes site name and country name
	$data .= "<div class='pageheader'>$name, $country [$code]</div>\n";

	# Show location map and some site info
	$data .=  "<table border=0 cellspacing=10 cellpadding=\"10\">";
	$data .=  "<tr><td width='400'>";
	$mapimage = "/gmd/dv/site/maps/$map";
	$absmapimage = dirname($_SERVER['SCRIPT_FILENAME']) . "/maps/$map";
	$data .=  "<img src='$mapimage' alt=''>";
	$data .=  "</td>\n";

	# Latitude info
	$data .=  "<td valign='top'>\n";
	$data .=  "<table align='center' border=0 cellpadding='20' cellspacing=1 class='table2'>";

	$data .=  "   <tr class='trcolor2'>";
	$data .=  "      <td>Country</td>";
	$data .= "<td>";
	$data .=  "   <img src=\"$flagurl\" alt=\"Country Flag\">\n";
	$data .= "<br>$country</td>";
	$data .=  "   <tr class='trcolor1'>";
	$data .=  "      <td>Latitude:</td>";
	if ( $lat >= 0 ) {
		$data .=  "<td>$lat&deg; North</td>";
	} else {
		$displaylat = abs($lat);
		$data .=  "<td>$displaylat&deg; South</td>";
	}
	$data .=  "   </tr>";

	# Longitude info
	$data .=  "   <tr class='trcolor2'>";
	$data .=  "      <td>Longitude:</td>";
	if ( $lon >= 0 ) {
		$data .=  "<td>$lon&deg; East</td>";
	} else {
		$displaylon = abs($lon);
		$data .=  "<td>$displaylon&deg; West</td>";
	}
	$data .=  " </tr>";

	# Elevation info
	$data .=  " <tr class='trcolor1'>";
	$data .=  "   <td>Elevation:</td>";
	$data .=  "   <td>$elev masl</td>";
	$data .=  " </tr>";

	# Time zone info
	$data .=  " <tr class='trcolor2'>";
	$data .=  "   <td>Time Zone:</td>";
	$data .=  "   <td>Local Time + $lst2utc hour(s) = UTC</td>";
	$data .=  " </tr>";

	# Contact info
	$query="SELECT * FROM site_contact WHERE site_id=$site_num";
#echo $query;
        $result=mysql_query($query);
$nrows = 0;
if ($result) {
	$nrows = mysql_num_rows($result);
}
	if ($nrows) {
		$r2 = mysql_fetch_object($result);
		$data .=  "<tr class='trcolor1'>";
		$data .= "  <td>Contact Name:</td>";
		if (!empty($r2->email)) {
			$data .= "  <td><a href='mailto:$r2->email'>$r2->contact_name</a></td>";
		} else {
			$data .= "  <td>$r2->contact_name</td>";
		}
		$data .= "</tr>";
		$data .=  "<tr class='trcolor2'>";
		$data .= "  <td>Address:</td>";
		$data .= "  <td>$r2->address1<br>";
		$data .= "    $r2->address2<br>$r2->city, $r2->state, $r2->zip, $r2->country</td>\n";
		$data .= "</tr>";
		$data .=  "<tr class='trcolor1'>";
		$data .= "<td>Phone:</td>";
		$data .= "<td>$r2->phone</td>";
		$data .= "</tr>";
		$data .=  "<tr class='trcolor2'>";
		$data .= "<td>Fax:</td>";
		$data .= "<td>$r2->fax</td>";
		$data .= "</tr>";
	}

#	if ($coopname != NULL) {
#		$data .=  "<tr class='trcolor2'><td colspan=2>";
#		$data .=  "<br>GMD Sampling at $name is in collaboration with ";
#		if ( $coopurl != "" ) {
#			$data .=  "<a href='$coopurl'>$coopname</a>";
#		} else {
#			$data .=  "$coopname";
#		}
#		if ($cooplogo != "" ) {
#			$logoimage = "/test/site/logos/$cooplogo";
#			$data .=  "<br><br><div align='center'><img src='$logoimage'alt='' width='120' height='120'></div>";
#		}
#		$data .=  "</td></tr>";
#	}
	$data .=  "</table>";

	# Photos
#	if ( !empty($gallery_id) ) {
#		$data .=  "<p>";
#		$url = "/gallery2/main.php?g2_itemId=$gallery_id";
#		$data .=  "<font class='announcement'><a href='$url'>Photo Gallery</a></font><br>\n";
#	}
	# Trajectory info
	$file1 = "/www/wwwnew/traj/plots/$lowcode.html";
	$file2 = "/www/wwwnew/dv/site/trajs/${lowcode}_traj.jpg";
	if (file_exists($file1) || file_exists($file2)) {
		$data .=  "<p>";
		$data .=  "<font class='announcement'>Atmospheric Transport</font><br>\n";
	}
#	if (file_exists($file1)) {
#		$file1a = "/traj/plots/$lowcode.html";
#		$data .=  "<a href='$file1a'>Recent $code Trajectories</a><br>\n";
#	}
	if (file_exists($file2)) {
		$file2a = "/gmd/dv/site/trajs/${lowcode}_traj.jpg";
		$data .=  "<a href='$file2a' border=1>Clustered summary of $code Trajectories</a><br>\n";
	}



	$data .=  "</td></tr></table><br>\n";

	# Description info
	if (!empty ($description)) {
		$data .=  "<font class='announcement'>Description</font><br>\n";
		$data .=  $description;
#		$data .=  "<p>";
	}

	# Project info
        $query  = "SELECT project.name,project_num,coop_agency,url ";
        $query .= "FROM project,site_project ";
        $query .= "WHERE site_project.site_num=$site_num ";
        $query .= "AND site_project.project_num=project.num ";
	$query .= "ORDER BY project_num ";

        $result=mysql_query($query);
        if (!$result) {
#                $data .=  '<br>Could not run query: ';
                return ($data);
        }

	$nrows = mysql_num_rows($result);
	if ($nrows > 0) {
		$data .= "<br>\n";
		$data .=  "<div class='searchheader'>GMD Projects at $name</div>\n";
	}

        while ($row = mysql_fetch_row($result)) {
		$data .= "<p>";
		$data .= "<font class='contentheading'>$row[0]</font><br>\n";
		if (!empty ($row[2])) {
			$data .= "Cooperating Agency: ";
			if (!empty($row[3])) {
				$data .= "<a href='$row[3]'>$row[2]</a><br>\n";
			} else {
				$data .= "$row[2]<br>\n";
			}
		}
		$projnum=$row[1];


		$query = "SELECT parameter_num,parameter.name,parameter.formula_html,first ";
		$query .= "FROM data_summary,parameter ";
		$query .= "WHERE site_num=$site_num ";
		$query .= "AND data_summary.parameter_num=parameter.num ";
		$query .= "AND project_num=$projnum; ";

		$result2=mysql_query($query) or die("query failed");
		$nrows = mysql_num_rows($result2);


		# For each project, list the parameters that are measured
		if ($nrows > 0) {
			$data .= "<div class='test'>";

			$data .=  "<table border=0 cellspacing='1' cellpadding='15' class='table2' width='80%'>";
			$data .=  "<tr>\n";
			$data .=  "<th bgcolor='#ffffff'>Parameter</th>\n";
			$data .=  "<th bgcolor='#ffffff'>Formula</th>\n";
			$data .=  "<th bgcolor='#ffffff'>Start Date</th>\n";
			$data .=  "</tr>";

			$foo = 0;
			while ($r = mysql_fetch_row($result2)) {

				if ($foo) {
					$data .=  "<tr class='trcolor2'>\n";
				} else {
					$data .=  "<tr class='trcolor1'>\n";
				}
				$foo = ! $foo;

				$data .=  "<td>$r[1]</td>\n";
				$data .=  "<td>$r[2]</td>\n";
				$data .=  "<td>$r[3]</td>\n";
				$data .=  "</tr>\n";
			}
			$data .=  "</table>\n";
			$data .= "</div>";
		}

	}

	return $data;
}

#################################################################
# Create the sql query string for selecting active sites.
# Use this function so the various php scripts all use the
# same dataset.
#################################################################
function getSiteSQL() {

	$sql  = "SELECT DISTINCT code,name,country,lat,lon,elev,project_num ";
	$sql .= "FROM site,site_project ";
	$sql .= "WHERE site.num=site_project.site_num ";
#	$sql .= "AND site_project.project_num = 3 ";
	$sql .= "AND (site_project.status_num=1 ";
#	$sql .= "OR site_project.status_num=3 ";
	$sql .= "OR site_project.status_num=5) ";
	$sql .= "AND lat>-90 AND lon>-900 ";
	$sql .= "ORDER BY project_num,code ";

	return $sql;
}

?>
