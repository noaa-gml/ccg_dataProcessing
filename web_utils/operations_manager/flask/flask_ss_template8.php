<?php
$siteLabel="SITE CODE 測站代碼";
#flask
$flaskLabel="FLASK # 瓶號 #";
$pumpLabel="pump 靠幫浦側";
$returnLabel="return 靠回送側";

#date & time
$dayLabel="DAY 日";
$monthLabel="MONTH 月";
$yearLabel="YEAR 年";
$hourLabel="HOUR 時";
$minuteLabel="MINUTE 分";
$universalTimeLabel="UNIVERSAL TIME (UTC) 世界協調時間";
$localStdLabel="LOCAL STANDARD TIME (LST) 當地標準時間";
$daylightSavingsLabel="DAYLIGHT SAVING TIME (DST) 日光節約時間";
$noteLabel="USE SAME TIME ZONE FOR BOTH DATE & TIME<br> 請使用相同時區的日期和時間";

#Lat, Lon & Alt
$latLabel="LATITUDE";
$lonLabel="LONGITUDE";
$sampleHeightLabel="SAMPLE DEPTH";

#wind
$windSpeedLabel="WIND SPEED 風速";
$relWindSpeedLabel="REL. WIND SPEED";
$metersPerSecLabel="m/s";
$knotsLabel="KNOTS";
$mphLabel="MPH";

$windDirectionLabel="WIND DIRECTION 風向";
$relWindDirectionLabel="REL. WIND DIRECTION";
$degreeLabel="(DEG)";
$obsWindDirectionLabel="OBS. WIND DIRECTION";

#Voltage,flow rage & pump pressure
$pad=str_repeat("_",12);#Some translations need this in the middle..
$voltageLabel="VOLTAGE 電壓 $pad";
$flowRateLabel="FLOW RATE 流速 $pad";
$pumpPressureLabel="PUMP PRESSURE 幫浦壓力 $pad";

#Remarks, observer, inventory & contact
$remarksLabel="REMARKS 備註";
$observerLabel="OBSERVER 採樣員";
$inventoryLabel="# OF UNSAMPLED BOXES 剩餘箱數";
$emailLabel="E-MAIL";

#LEDs
#$LEDInstructionLabel="PLEASE CHECK WHICH LAMPS WERE ON<BR>WHEN SAMPLE ENDED";
#$LEDInstructionLabel="PLEASE CHECK WHICH LAMPS WERE ON<BR>WHEN SAMPLE ENDED 採樣完成後請確認指示燈號如下所列";
$LEDInstructionLabel="PLEASE CHECK WHICH LAMPS WERE ON<BR>WHEN SAMPLE ENDED 採樣完成後,請記錄亮起的指示燈";

#Shipping box
#$doNotWriteInThisBoxLabel="DO NOT WRITE IN THIS BOX";
$doNotWriteInThisBoxLabel="DO NOT WRITE IN THIS BOX 此框格內欄位不必填寫";#Ou-Yang, and this one...

require_once("flask_ss_template_b.php");#new test layout
#require_once("flask_ss_template.php");
exit;
?>
