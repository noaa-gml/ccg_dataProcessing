<?php

# Sample sheet translation table - Korean

$siteLabel="SITE CODE 사이트 코드";

#flask

$flaskLabel="FLASK # 플라스크 번호 #";

$pumpLabel="pump 펌프";

$returnLabel="return 반환";

#date & time

$dayLabel="DAY 일";

$monthLabel="MONTH 월";

$yearLabel="YEAR 년";

$hourLabel="HOUR 시";

$minuteLabel="MINUTE 분";

$universalTimeLabel="UNIVERSAL TIME (UTC) 세계 표준시";

$localStdLabel="LOCAL STANDARD TIME (LST) 현지 표준시";

$daylightSavingsLabel="DAYLIGHT SAVING TIME (DST) 일광 절약 시간";

$noteLabel="USE SAME TIME ZONE FOR BOTH DATE & TIME<br> 동일한 시간대의 날짜와 시간을 사용하세요";

#Lat, Lon & Alt

$latLabel="LATITUDE 위도";

$lonLabel="LONGITUDE 경도";

$sampleHeightLabel="SAMPLE DEPTH 샘플 깊이";

#wind

$windSpeedLabel="WIND SPEED 풍속";

$relWindSpeedLabel="REL. WIND SPEED 상대 풍속";

$metersPerSecLabel="m/s";

$knotsLabel="KNOTS";

$mphLabel="MPH";

$windDirectionLabel="WIND DIRECTION 풍향";

$relWindDirectionLabel="REL. WIND DIRECTION 상대 풍향";

$degreeLabel="(DEG)";

$obsWindDirectionLabel="OBS. WIND DIRECTION 관측된 풍향";

#Voltage, flow rate & pump pressure

$pad=str_repeat("_",12);#Some translations need this in the middle..

$voltageLabel="VOLTAGE 전압 $pad";

$flowRateLabel="FLOW RATE 유속 $pad";

$pumpPressureLabel="PUMP PRESSURE 펌프 압력 $pad";

#Remarks, observer, inventory & contact

$remarksLabel="REMARKS 비고";

$observerLabel="OBSERVER 관측자";

$inventoryLabel="# OF UNSAMPLED BOXES 남은 박스 수";

$emailLabel="E-MAIL";

#LEDs

#$LEDInstructionLabel="PLEASE CHECK WHICH LAMPS WERE ON<BR>WHEN SAMPLE ENDED";

$LEDInstructionLabel="PLEASE CHECK WHICH LAMPS WERE ON WHEN SAMPLE ENDED<br>샘플이 끝났을 때 어떤 램프가 켜져 있는지 확인하십시오";

#Shipping box

#$doNotWriteInThisBoxLabel="DO NOT WRITE IN THIS BOX";

$doNotWriteInThisBoxLabel="DO NOT WRITE IN THIS BOX<br>이 박스에 쓰지 마십시오";

require_once("flask_ss_template_b.php");#new test layout

#require_once("flask_ss_template.php");

exit;

?>

