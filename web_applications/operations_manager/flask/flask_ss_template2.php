<?PHP
#
# SAMPLE SHEET - FRENCH
#
# JWM - 9/16 - Rewrote html template logic to have a single template with translation table.
#  See flask_ss_template1.php for english version of these variables.

$siteLabel="CODE DE LA STATION";

#flask
$flaskLabel="NUM&Eacute;RO DU FLACON";
$pumpLabel="pompe";
$returnLabel="retour";

#date & time
$dayLabel="JOUR";
$monthLabel="MOIS";
$yearLabel="ANN&Eacute;E";
$hourLabel="HEURE";
$minuteLabel="MINUTE";
$universalTimeLabel="TEMPS UNIVERSEL (UTC)";
$localStdLabel="HEURE LOCALE (LST)";
$daylightSavingsLabel="HEURE D'&Eacute;T&Eacute; (DST)";
$noteLabel="SVP, UTILISEZ LE M&Ecirc;ME FUSEAU HORAIRE POUR LA DATE ET L'HEURE";#"USE SAME TIME ZONE FOR BOTH DATE & TIME";

#Lat, Lon & Alt
$latLabel="LATITUDE";
$lonLabel="LONGITUDE";
$sampleHeightLabel="SAMPLE HAUTEUR";

#Wind
$windSpeedLabel="VITESSE DU VENT";
$relWindSpeedLabel="VITESSE DU VENT RELATIF";
$metersPerSecLabel="m/s";
$knotsLabel="N&OElig;UD";
$mphLabel="";

$windDirectionLabel="DIRECTION DU VENT";
$relWindDirectionLabel="DIRECTION DU VENT RELATIF";
$degreeLabel="(DEG)";
$obsWindDirectionLabel="OBS. DIRECTION DU VENT";

#Voltage,flow rage & pump pressure
$pad=str_repeat("_",12);#Some translations need this in the middle..
$voltageLabel="TENSION DE LA BATTERIE $pad";
$flowRateLabel="D&Eacute;BIT D'AIR $pad";
$pumpPressureLabel="PRESSION FINALE DANS LES FLACONS $pad";#"PSI DE MAKS $pad";

#Remarks, observer, inventory & contact
$remarksLabel="REMARQUES";
$observerLabel="OPERATEUR";
$inventoryLabel="NOMBRE DE CAISSES RESTANTES";
$emailLabel="E-MAIL";

#LEDs
$LEDInstructionLabel="S'IL VOUS PLAÎT VÉRIFIER QUI ÉTAIENT FEUX SUR<br> QUAND SAMPLE TERMINÉ";

#Shipping box
$doNotWriteInThisBoxLabel="N'&Eacute;CRIVEZ PAS DANS LA CASE CI-DESSOUS";

require_once("flask_ss_template.php");

exit;
