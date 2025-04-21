<?php

# Sample sheet translation table - Simplified Chinese



$siteLabel="SITE CODE 观测站代码";

#flask

$flaskLabel="FLASK # 采样瓶号 #";

$pumpLabel="pump 靠泵侧";

$returnLabel="return 靠回送侧";



#date & time

$dayLabel="DAY 日";

$monthLabel="MONTH 月";

$yearLabel="YEAR 年";

$hourLabel="HOUR 时";

$minuteLabel="MINUTE 分";

$universalTimeLabel="UNIVERSAL TIME (UTC) 世界协调时间";

$localStdLabel="LOCAL STANDARD TIME (LST) 当地标准时间";

$daylightSavingsLabel="DAYLIGHT SAVING TIME (DST) 夏令时";

$noteLabel="USE SAME TIME ZONE FOR BOTH DATE & TIME<br> 请使用相同时区的日期和时间";



#Lat, Lon & Alt

$latLabel="LATITUDE";

$lonLabel="LONGITUDE";

$sampleHeightLabel="SAMPLE DEPTH";



#wind

$windSpeedLabel="WIND SPEED 风速";

$relWindSpeedLabel="REL. WIND SPEED";

$metersPerSecLabel="m/s";

$knotsLabel="KNOTS";

$mphLabel="MPH";



$windDirectionLabel="WIND DIRECTION 风向";

$relWindDirectionLabel="REL. WIND DIRECTION";

$degreeLabel="(DEG)";

$obsWindDirectionLabel="OBS. WIND DIRECTION";



#Voltage,flow rage & pump pressure

$pad=str_repeat("_",12);#Some translations need this in the middle..

$voltageLabel="VOLTAGE 电压 $pad";

$flowRateLabel="FLOW RATE 流速 $pad";

$pumpPressureLabel="PUMP PRESSURE 泵压 $pad";



#Remarks, observer, inventory & contact

$remarksLabel="REMARKS 备注";

$observerLabel="OBSERVER 采样员";

$inventoryLabel="# OF UNSAMPLED BOXES 剩余未采样箱数";

$emailLabel="E-MAIL";



#LEDs

#$LEDInstructionLabel="PLEASE CHECK WHICH LAMPS WERE ON<BR>WHEN SAMPLE ENDED";

$LEDInstructionLabel="PLEASE CHECK WHICH LAMPS WERE ON<BR>WHEN SAMPLE ENDED 请记录采样完成后亮起的指示灯";



#Shipping box

#$doNotWriteInThisBoxLabel="DO NOT WRITE IN THIS BOX";

$doNotWriteInThisBoxLabel="DO NOT WRITE IN THIS BOX 此框格内不必填写";



require_once("flask_ss_template_b.php");#new test layout

#require_once("flask_ss_template.php");

exit;

?>

