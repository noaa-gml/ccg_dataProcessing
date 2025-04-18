<?php
function bs_table($a,$options=[]){
    /*
        Generate table from db query resultset $a.  Result set comes from doquery() lib.
        any column with a bs_ name prefix will be ignored in the output.  See below for
        details on when to use.
        #$options can override $fullOpts defaults
    */
    $fullOpts=array(
        'onClick'=>"",#If passed, js ajax loads switch.php with a doWhat=$onClick.  Your switch must be programmed to handle it.
            #Optional; if resultset columns bs_param1, bs_param2 & bs_param3 are present, they are passed along too.
            #bs_param1 is pkey by convention.  Note; embedded quotes or single quotes may cause issues.  attempt to sanitize below.
        'onClickResultDiv'=>'',#Results from above are placed in this div ID.
            #Defaults to the 'other' main content div (adj or fixed depending on where searchform results are sent) (in js click handler).
            #Can use 'bs_ajaxJSDiv' for only js responses (alerts, ...)
        'onClickIncludeSearchForm'=>False,#serializes and passes bs_sideBarForm inputs too.
        'onClickJS'=>'',#Roll your own click handler.  Don't add parens, just the js function name.
            #This will pass clicked rowID, targID (supplied below) and above 3 params like this: {$onClickJS}('$rowID','$targID','$p1','$p2','$p3')
        'onClickJSTargID'=>'',#Go's with onClickJS.  Optional if caller needs it.

        'rowStriped'=>false,#alternating colors on rows
        'bordered'=>true,#Borders for all cells
        'theme'=>'default',#dark,light,default,primary,secondary,success,danger,warning,info https://getbootstrap.com/docs/5.3/content/tables/#variants
        'headerTheme'=>'primary',#dark,light,default,primary,secondary,success,danger,warning,info https://getbootstrap.com/docs/5.3/content/tables/#variants
        'width'=>"",#in pixels or percent; eg 500px or 100%.
        'height'=>"",#in pixels or percent; eg 500px or 50%
        'divID'=>uniqid('bs_'),
        'selectedRowKey'=>'',#If selectedRowKey && clickSelectedRowKey && bs_param1 && an onClick is passed, row with selectedRowKey=bs_param1 is 'clicked' on load
        'clickSelectedRowKey'=>true,#Passed with above to auto click selected row.  (NOT WORKING YET)If false, we highlight and scroll into view.
        'floatHeader'=>true,
        'editableField'=>'',
        'passRowIDToOnClick'=>false,
        'caption'=>'',#Title to add at bottom of table
        'captionTop'=>True,#put caption at top
        'autoWidth'=>false,#true to size table to content, false to use 100% available
    );
    extract(bs_setOptions($fullOpts,$options));#Set default options and overrides into namespace


    $html="";
    if($a){
        $i=1;$j=1;$onLoadClick='';
        //Set up format and layout options
        $striped=($rowStriped)?"table-striped":"";
        $border=($bordered)?"table-bordered":'';
        $w=($width)?"width:$width;":"";
        $h=($height)?"height:$height;":"";
        $ttheme=($theme)?"table-$theme":"";
        $htheme=($headerTheme)?"table-$headerTheme":"";
        $hover=($onClick || $onClickJS)?"table-hover bs_selectable":'';
        $caption=($caption)?"<caption>$caption</caption>":"";
        $captionTop=($captionTop)?"caption-top":'';
        $awidth=($autoWidth)?"w-auto":'';
        if($w || $h)$html.="<div class='bs_printTableContainer' style='$w $h'>";#only add if size was set so that it can scroll in parent container
        $html.="<table class='table $ttheme $striped $border $hover table-sm $captionTop $awidth' id='$divID' >$caption";
        foreach($a as $row){
            if($i==1){#header row
                $html.="<thead class='$htheme bs_border'><tr style='position:sticky;top:0;'>";$i++;
                foreach($row as $key=>$val){
                    if(!bs_startsWith($key,"bs_")){#Skip any that should be hidden.
                        $html.="<th scope='col'>$key</th>";
                    }
                    $j++;
                }
                $html.="</tr></thead><tbody>";
            }

            #Body
            #Set up click handlers if needed
            if($onClick || $onClickJS){
                $p1=(isset($row['bs_param1']))?$row['bs_param1']:'';
                $p2=(isset($row['bs_param2']))?$row['bs_param2']:'';
                $p3=(isset($row['bs_param3']))?$row['bs_param3']:'';
                #$p1=addslashes(htmlspecialchars($p1));#skip this as it can cause issues
                #$p2=addslashes(htmlspecialchars($p2));#Attempt to sanitize
                #$p3=addslashes(htmlspecialchars($p3));

                $inc=($onClickIncludeSearchForm)?"true":"false";
                $rowID=uniqid('bs_');
                $destDiv=($onClickResultDiv)?"'$onClickResultDiv'":'bs_tableClickedDestDiv';//Default to 'the other' content div from where search form submits to. set in bs_indexInclude.php.  Note quoting for js var
                if($onClickJS){
                    $click="id='$rowID' class='bs_tableRow' onclick=\"{$onClickJS}('$rowID','$onClickJSTargID','$p1','$p2','$p3');\"";
                    #var_dump($click);
                }else $click="id='$rowID' class='bs_tableRow' onclick=\"bs_tableClicked('$rowID','$onClick',$destDiv,$inc,'$p1','$p2','$p3','$divID');\"";#Note; jwm 9/24; added divID here for use in js, but not above by custom/passed handler as I didn't want to affect callers.
                //See if we need to simulate a click on load
                if($selectedRowKey && $p1==$selectedRowKey){
                    if($clickSelectedRowKey){
                        $onLoadClick="bs_tableClicked('$rowID','$onClick',$destDiv,$inc,'$p1','$p2','$p3','$divID');";                #var_dump($onLoadClick);
                    }else{
                        $onLoadClick="
                        bs_getEl('$rowID').scrollIntoView({
                            behavior: 'smooth', // Smooth scrolling
                            block: 'center'     // Scroll to center of the view
                        });
                        bs_showTableRowClicked('$divID','$rowID');";
                    }
                }
            }else{$click='';}
            $html.="<tr $click>";$j=1;
            foreach($row as $key=>$val){
                if(!bs_startsWith($key,"bs_")){#Skip any that should be hidden.
                    $html.="<td>$val</td>";
                }
                $j++;
            }
            $html.="</tr>";
        }
        $html.="</tbody></table>";
        if($w || $h)$html.="</div>";
        if($onLoadClick)$html.="<script>$onLoadClick</script>";

    }else{$html="No results";}
    return $html;
}
function bs_sortPlotData($a){
    /*Prepare manipulated or created plot data by sorting by x,series, y (for when not sorted in db)*/
    usort($a, function($a, $b) {
        if ($a['x'] == $b['x']) {
            if ($a['series'] == $b['series']) {
                return bs_comp($a['y'],$b['y']);
            }
            return bs_comp($a['series'],$b['series']);
        }
        return bs_comp($a['x'],$b['x']);
    });
    return $a;
}
function bs_comp($a,$b){
    /*From future for <=> operator, for use on older systems
    It returns -1, 0 or 1 when $a is respectively less than, equal to, or greater than $b
    */
    if($a<$b)return -1;
    elseif($a==$b)return 0;
    else return 1;
}

function bs_plot($a,$options=[]){
    /*Returns js for dygraph style plot
    $a is db result set from doquery()
        required COLS: x,series,y
        required SORT: x,series,y
        series is the label for series.   x is a datetime, y is value.
        Can use bs_sortPlotData() to sort if not done in db (manipulated in php)

        if 'err' col is included and not -999.99, error bars are printed.  Logic currently looks at first row of first series to see if err
        col exists.  It sets err to 0 on all following datasets missing err col or with value =-999.99


    Any options can be passed in options array and will override $dfltOptions below.

    */

    $dfltOptions=array(
        "plotVar"=>uniqid('dgplt_'), #pass a string variable name to use as js handle.
        "xIsDate"=>true, #false if xaxis is a number
        'drawPoints'=>true,
        'fillGraph'=>false, #fills in area under plot line with color
        'connectSeparatedPoints'=>true, #draws line between missing points for series (when more than one series and one is missing data for a date)
        'staticHTML'=>false, #wraps the js in an on load event listner so that it doesn't run until page is loaded.  This is needed when standalone html is created (no ajax to handle)
        'drawGapEdgePoints'=>true,
        'stackedGraph'=>false,
        'pointSize'=>1.5, #is point size, pass drawPoints=false to hide.
        'strokeWidth'=>1, #is the line width.  Pass 'false' for no lines
        'strokeBorderWidth'=>null,
        'legend'=>'always', #'always' shows legend, 'onmouseover' only when mouse over, 'follow' to follow cursor
        'title'=>'',
        'rollPeriod'=>1,
        'showControls'=>true, #whether to show the dynamic widgets or not
        'optControl'=>'', #can be anything the caller wants to pass.  It gets put right next to the save btn.  Current use case is a share/email link for icp.
        'labelsDiv'=>'', #put legend in external divid
        'xRangePad'=>10, #points on either side of first/last data points to make sure visible.
        'legendFormatter'=>'default', #side is formatted for longer list and should be used with a labelsDiv on side (see comparisons_funcs.php->plotComparison() for example),
                    #-default is overlaid on plot.  You can also pass a dynamic function for custom legend formatter . See bs_printDygraphPlot_legendFormatter_default() for example.  But I think it would be best to add a new keyword (like side), create a function like others and then add below to legFormatter so that you can pass the plotvar and options to do toggling.
        'legendSide'=>'left',
        'horzLines'=>array(), #is an array of line arrays like this for 2 lines:
                            #$l=array();
                            #$l[]=array("color"=>'green',"y"=>$targ,"lineWidth"=>".5");
                            #$l[]=array("color"=>'green',"y"=>-$targ,"lineWidth"=>".5");
                            #$plotSettings['horzLines']=$l;
        'vertLines'=>array(), #is an array of line arrays like this for 1 line:
                            #$plotSettings['vertLines']=array(array("color"=>'black',"x"=>'2010-02-01',"lineWidth"=>"5"));
        'seriesOpts'=>array(), #is an array of per series options like this:
                            #$plotSettings['seriesOpts']=array('2:CSIRO flask'=>array('strokeWidth'=>3));
        'ylabel'=>'',
        'xlabel'=>'',
        'width'=>'', #plot width, leave blank to fill available.  with units.  Must pass height too.
        'height'=>'' #plot height, leave blank to fill available.  with units.  Must pass width too.
    );


    #Note legend set to onmouseover causes weird issues when title is added
    $noPassOptions=array('plotVar','xIsDate','showControls','staticHTML','optControl','legendFormatter','legendSide','horzLines','vertLines','seriesOpts');//Options that don't get automatically passed to dygraph
    foreach($options as $key=>$val){$dfltOptions[$key]=$val;}



    if($a){
        $plotVar=$dfltOptions['plotVar'];
        $xIsDate=$dfltOptions['xIsDate'];
        $divID=$plotVar."_div";
        $series=array_values(array_unique(arrayFromCol($a,'series')));#re-indexed(from zero), uniqued, list of series in dataset
        sort($series);#Make sure in series order (dataset num should be first char).  Can get out of order if 1 set starts before another.
        $indexes=array_flip($series);#get the indexes for each to make below easier
        $data=[];$opts='';$json='';$static=$dfltOptions['staticHTML'];$dups=array();
        $aFill=array_fill(0,count($series),'null');#fill series array with default NaNs.  1 y val for each series
        #loop through extracting the unique dates
        foreach($a as $row){
            $data[$row['x']]=$aFill;
        }

        #now add series information.  This is complicated because we don't want to duplicate datetimes for flask pairs so that they are visible/highlightable
        #Foreach time, we'll build an array of series values, defaulting null for series without a value on that date.  If a series has
        #more than one val for that dt, we'll put into a tmp array ($dups) to add later.
        #NOTE; this hasn't been tested on non-datetime data yet.
        $dfltOptions['errorBars']=(isset($a[0]['err']));
        foreach($a as $row){
            #when passing stddev, value,stddev must be in an array
            if($dfltOptions['errorBars']){
                if(!isset($row['err']))$err=0;#this series didn't have it
                $err=($row['err']==-999.99)?0:$row['err'];#default 0 if not set
                $val="[".$row['y'].",".$err."]";
            }else{
                $val=$row['y'];
            }

            if($data[$row['x']][$indexes[$row['series']]]=='null'){#put the y val in the series slot of data array for date x.
                $data[$row['x']][$indexes[$row['series']]]=$val;
            }else{
                #already have a value for this entry, add to a tmp array to merge in later
                $r=$aFill;
                $r[$indexes[$row['series']]]=$val;#This is the y value for series pos
                if(!isset($dups[$row['x']]))$dups[$row['x']]=array();#empty array for 2nd+ dups
                $dups[$row['x']][]=$r;#add this dup into array.
            }
        }
        #Now we can create the json output.  We'll roll own because we need to tweak things a bit (new Date()...)

        foreach($data as $x=>$vals){
            $item=($xIsDate)?"[".bs_getJSTimestamp($x,false).",":"[$x,";#dates need date obj creator
            $item.=implode(',',$vals)."],";#comma deliminate values()
            $json.=$item;
            if(isset($dups[$x])){#one or more entries with same time, add in with a pad of 10 microsecond to separate. Same logic as above.
                $i=1;
                foreach($dups[$x] as $r){
                    $item=($xIsDate)?"[".bs_getJSTimestamp($x,false,$i*10).",":"[$x,";#dates need date obj creator, pad by 10+ microsecond
                    $item.=implode(',',$r)."],";#comma deliminate values()
                    $json.=$item;
                    $i++;
                }

            }
        }
        $json="[".substr($json,0,-1)."]";#strip trailing ,
        array_unshift($series,"X");#needed by options
        $opts="{labels: ".json_encode($series);
        foreach($dfltOptions as $key=>$val){if(!in_array($key,$noPassOptions))$opts.=",$key:".bs_boolstr($val);}#Note some of these aren't used by dygraph (like staticHTML) (noPassOptions)

        #Legend formatter.
        $legFormatter=$dfltOptions['legendFormatter'];
        if($dfltOptions['legendFormatter']=='side')
            $legFormatter=bs_printDygraphPlot_legendFormatter_sideJS($plotVar,$dfltOptions);
        elseif($dfltOptions['legendFormatter']=='default')
            $legFormatter=bs_printDygraphPlot_legendFormatter_default($plotVar,$dfltOptions);


        $horzLines='';
        if(isset($dfltOptions["horzLines"]) && $dfltOptions["horzLines"]){
            #add in calls to set horizontal lines.
            $x1=$a[0]['x'];
            $x2=$a[count($a)-1]['x'];
            if($xIsDate){
                $x1=bs_getJSTimestamp($x1,false);
                $x2=bs_getJSTimestamp($x2,false);
            }
            foreach($dfltOptions["horzLines"] as $row){#$y=>$color){
                $y=$row['y'];$lineWidth=$row['lineWidth'];$color=$row['color'];
                $horzLines.="dygraph_horzLine(ctx,area,dygraph,$x1,$x2,$y,'$color',$lineWidth);";
            }
        }
        #dygraph_vertLine
        $vertLines='';
        if(isset($dfltOptions["vertLines"]) && $dfltOptions["vertLines"]){
            #add in calls to set vert lines.dygraph_vertLine(ctx,area,dygraph,y1,y2,x,color,lineWidth){
            $ys=arrayFromCol($a,'y');
            $y1=min($ys);
            $y2=max($ys);
            #var_dump($dfltOptions["vertLines"]);
            foreach($dfltOptions["vertLines"] as $row){#$y=>$color){
                $x=$row['x'];$lineWidth=$row['lineWidth'];$color=$row['color'];
                $vertLines.="dygraph_vertLine(ctx,area,dygraph,$y1,$y2,".bs_getJSTimestamp($x).",'$color',$lineWidth);";
            }
        }
        $border="underlayCallback: function(ctx, area, dygraph) {
                         ctx.strokeStyle = 'black';
                         ctx.strokeRect(area.x, area.y, area.w, area.h);
                         $horzLines;
                         $vertLines;
                     }";
        $seriesOptions="";
        if(isset($dfltOptions['seriesOpts']) && $dfltOptions['seriesOpts']){
            $seriesOptions="series: ".json_encode($dfltOptions['seriesOpts']).",";
            #foreach($dfltOptions['seriesOpts'] as $k=>$v){
            #    appendToList2($seriesOptions,"'$k':$v");
            #}
            #$seriesOptions="series: {".$seriesOptions."},";
            #$seriesOptions="series: {'1:NOAA flask - 2:CSIRO flask_curve':{'plotter': smoothPlotter}},";
        }
        $opts.=",labelsUTC: true,$border,legendFormatter:$legFormatter,$seriesOptions plugins:[dg_doubleClickZoomOutPlugin]";//Handles missing series data for a date.  see dbutils.js->dygraphLegendFormatter()
        #$opts.=",showRoller:true,rollPeriod:60";#,valueRange:[414,416]
        #$opts.=",series:{'".$series[1]."':{strokeWidth:3}}";
        $opts.="}";

        $plotOptions='';
        if(!$static && $dfltOptions['showControls']){
            $plotSettings=bs_dygraphSettingsDiv($plotVar,$dfltOptions,$series);#Controls to manipulate plot.
            $plotSettings=bs_offCanvasArea("{$divID}_plotSettings","Plot Options","Plot Options",$plotSettings);#Turn into a button

            $js="dg_saveAsPng('$divID',$plotVar);";
            $saveBtn=bs_button('Save',$js,['btnClass'=>'btn-secondary']);
            #bs_saveDivAsImgBtn($divID);

            $plotOptions=$plotSettings.$saveBtn;
        }
        $plotOptions='';####not working yet.


        $vars="var opts=$opts;\nvar data=$json;\n var $plotVar=false;";
        $plot="var $plotVar=new Dygraph(document.getElementById(\"$divID\"),data,opts);";
        #Tried to pass options into plot var for use in js legend formatters (xisdate, but also could use to toggle) but can't seem to get to it.  I think this will be the method to do it though, so need to tweak a bit more_results()
        #$plot.="opts.xIsDate=".boolstr($xIsDate).";";
        if($static){#Add a window load event listener for the plot so js will run.  Wrap in delims so the plot viewer page (icp2_plots) can strip out.
            #$plot="//STATIC_START\n window.addEventListener('load', (event) => {\n //STATIC_END\n $plot \n //STATIC_START \n });\n //STATIC_END";
            $plot='//STATIC_START
                $(function(){
                //STATIC_END
                    '.$plot.'
                //STATIC_START
                });
                //STATIC_END';
        }
        /*I think this works..
            It was difficult to get 100% sizing to work because of dygraph limitations.  It seems to need an actual value set in parent
            to be able to set initial size correctly.  So after trying several variations, we set to small size then call a js
            script toresize to max available.  That call is on timer to let execution cycle finish and get all sizes set.  On some
            browsers (chrome atleast) the  js text in script tags was getting used to figure the div height for some reason. Might have to
            do with how the ajax logic is processing scripts.  This seems to resolve issues with only penalty that it has to do an
            immeadiate resize on load, which doesn't seem to slow down too much.
            Note we only do this when no size set
        */
        $width=$dfltOptions['width'];$height=$dfltOptions['height'];
        if($width && $height){
            $resizejs="";
        }else{
            $resizejs="setTimeout(function(){ dg_size('{$divID}');$plotVar.resize(); },1);";
            $width='200px';$height='100px';#tmp values, will get reset to 100%
        }
        $html="
            <div id='{$divID}_outer' class='dg_containerDiv'>
             <div id='{$divID}' style='width:$width;height:$height;'></div>
             <div id='{$divID}_options'>$plotOptions</div>
             <script> $vars $plot $resizejs </script>
            </div>
        ";#<div id='{$divID}_yLabel' class='dg_yLabel h5' >asdf</div>


    }else $html='No Data';

    return $html;
}
function bs_downloadJSON($data,$fileName='data.json'){
    #Takes $data and sends as json stream to client.
    #If filename passed, this sends as a download, otherwise streams directly (api call)
    #This exits after complete.  You can't have printed before calling this.
    #See downloadCSVLink() in htmlutils for how to set up a link.
    header('Content-Type: application/ld+json; charset=utf-8');
    header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
    header("Expires: 0");
    header("Pragma: no-cache");
    if($fileName){
        header("Content-Disposition: attachment; filename={$fileName}");
        header('Content-Description: File Transfer');
    }
    echo json_encode($data, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
    exit; // Stop further processing
}
function bs_downloadCSV($a,$fileName='data.csv',$delimiter=',',$enclosure='"'){
    #Takes query result and sends csv stream to client. Colnames are preserved.  This exits after complete.  You can't have printed before calling this.
    #Main logic cribbed from Aaron Campbell (http://ran.ge/2009/10/27/howto-create-stream-csv-php/)  Thanks!
    #$a=doquery("select * from icp.sample_data");
    #$delimiter is the field separator; can be any single string. pass "\t" for tab
    #$enclosure is the string quoting.
    #See downloadCSVLink() in htmlutils for how to set up a link.

    header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
    header('Content-Description: File Transfer');
    header("Content-type: text/csv; charset=utf-8");
    header("Content-Disposition: attachment; filename={$fileName}");
    header("Expires: 0");
    header("Pragma: public");

    $fh = @fopen( 'php://output', 'w' );

    $headerDisplayed = false;

    foreach ( $a as $data ) {
        // Add a header row if it hasn't been added yet
        if ( !$headerDisplayed ) {
            // Use the keys from $data as the titles
            fputcsv($fh, array_keys($data),$delimiter,$enclosure);
            $headerDisplayed = true;
        }

        // Put the data into the stream
        fputcsv($fh, $data,$delimiter,$enclosure);
    }
    // Close the file
    fclose($fh);
    // Make sure nothing else is sent, our file is done
    exit;
}
function bs_printDygraphPlot_legendFormatter_sideJS($plotVar,$options){
    #returns js function for side legend.  We do dynamically to make it easier to attache to correct plotvar.
    #note; use single outer quotes to prevent js $ syntax from expanding in php.
    if($options['xIsDate']){#parse and formate date
        $xlabel='
            var d=new Date(data.x);
            if(d != "Invalid Date" && element.yHTML){
                var mm = d.getUTCMonth() + 1; // getMonth() is zero-based
                var dd = d.getUTCDate();
                var yy = d.getUTCFullYear();
                xlabel=String(yy+"-"+mm+ "-" +dd);
            }';
    }else{#pass straight through (x isn't a date)
        $xlabel="if (element.yHTML){xlabel=String(data.x);}else{xlabel='';}";
    }
    $toggleJS='onclick="dygraph_toggleSeriesVisibility(\''.$plotVar.'\',${i});" title="Click to toggle"';

    $js='
        function(data) {
            var i=0;var t="";
            return data.series.map(element => {
            var xlabel="";
            '.$xlabel.'

            t = `<div style="width:100%;border-bottom:thin solid silver;">
                    <span style="font-weight:bold; color:${element.color};cursor: pointer;" '.$toggleJS.' >${element.labelHTML}:</span>
                    <span class="data">${element.yHTML || "<br>"}</span><br>
                    <span class="tiny_ital">${xlabel || "<br>"}</span></div>`;
            i++;
            return t;
            }).join("");
        }
        ';
    return $js;
}
function bs_printDygraphPlot_legendFormatter_default($plotVar,$options){
    #returns js function for  legend.  We do dynamically to make it easier to attache to correct plotvar.
    #note; use single outer quotes to prevent js $ syntax from expanding in php.
    if($options['xIsDate']){#parse and formate date
        $xlabel='
            var d=new Date(data.x);
            if(d != "Invalid Date" && element.yHTML){
                var mm = d.getUTCMonth() + 1; // getMonth() is zero-based
                var dd = d.getUTCDate(); var yy = d.getUTCFullYear(); var hh = d.getUTCHours();
                var m = d.getUTCMinutes(); var ss = d.getUTCSeconds();
                var df= yy + "-" + ("0" + mm).slice(-2)+"-"+("0"+dd).slice(-2);
                var tt= ("0" + hh).slice(-2) + ":" + ("0" + m).slice(-2)+":"+("0"+ss).slice(-2);//zero pad
                xlabel=String(df+"<br><span class=\'tiny_ital\' >"+tt+"Z</span>");
            }';
    }else{#pass straight through (x isn't a date)
        $xlabel="if (data.x == null){xlabel='';}else{xlabel=String(data.x);}";
    }
    $toggleJS='onclick="dygraph_toggleSeriesVisibility(\''.$plotVar.'\',${i});" title="Click to toggle"';

    $js='
    function(data) {

        var i=0;//track index so we can add a toggle to title.

        return "<table width=\'100%\' class=\'thinBorderedTable\'>"+data.series.map(element => {
            var d=new Date(data.x);var xlabel="";var t="";
            '.$xlabel.'
            t=`<tr class="border">
                    <td align="left" valign="top"><div class="title5" style="color:${element.color};cursor:pointer;" '.$toggleJS.'>${element.labelHTML}</div></td>
                    <td align="left" valign="top"><span class="sm_data bold" style="width:100%;">${element.yHTML || " "}&nbsp;</span></td>
                    <td align="right"><div class="sm_data" style="white-space: nowrap;">${xlabel}</td>

               </tr>
            `;
            i++;
            return t
        }).join("")+"</table>";
    }';
return $js;

}

function bs_saveDivAsImgBtn($divID,$btnText='Save',$filename='plot.png',$showSaveButtonImage=false){
    /*IN PROGRESS Returns a save button that will make an image of passed div and prompt to save to disk.  Doesn't work with ie.*/
    $js="dg_saveAsPng('$divID','$filename');";
    $btn=bs_button($btnText,$js,['btnClass'=>'btn-secondary']);
    return $btn;
}

function bs_dygraphSettingsDiv($plotVar,$options,$series){
    $html="Options<br>more options";
    return $html;
}
function bs_dygraphSettingsDivOLD($plotVar,$options,$series){#getStringInput($id,$val,$size='12',$class='',$placeholder=''){
    /*returns a settings widget to edit current plot.
     Be careful of various states of plotVar.  String in php , var in js.  */

    extract($options);//bring all into scope
    #".getCheckBoxInput('drawPoints_'.$plotVar,'Draw points',$drawPoints,$plotVar."_update_cb")."
    #".getCheckBoxInput('connectSeparatedPoints_'.$plotVar,'Connect separated points',$connectSeparatedPoints,$plotVar."_update_cb")."
    # ".getCheckBoxInput('drawGapEdgePoints_'.$plotVar,'Draw edge points',$drawGapEdgePoints,$plotVar."_update_cb")."
    $print='';#printDivButton('Print',$plotVar."_div",false);
    $print='';//Not really needed and we're space constrained
    $save='';#saveDivButton('Save',$plotVar."_div",'plot.png',false);
    #toggle plots
    $t=array_shift($series);$toggle='';//Remove the X first element
    if(count($series)>1){
        $toggle="Toggle ";
        foreach($series as $i=>$sn){$toggle.="<span class='spanbtn' onclick='dygraph_toggleSeriesVisibility(\"{$plotVar}\",$i)'><span>".($i+1)."</span></span> ";}
    }
    ###TAKING out toggle for now, it's in the legend
    $toggle='';

    #line border doesn't work great.
    #Line border:".getSelectFromList('strokeBorderWidth_'.$plotVar,'0,.5,1,1.5,2',$strokeBorderWidth,0,$plotVar."_update_inp('strokeBorderWidth')")."
    $colors="";
    $initLegendPos=($options['legendSide']=='left')?"LL":"RR";
    $optControl=$options['optControl'];
    #foreach($series as $i=>$sn){$colors.=bs_input('color',$plotVar."_{$i}_color",'Color','"#f00",['class'=>"{$plotVar}_color color_picker"])");}
    $colors=toggleJquerySelector("#{$plotVar}_color_picker_span",'Colors','hide','','',false)."<span id='{$plotVar}_color_picker_span'>$colors</span>";
    #$strokeWidthSel=getSelectFromList('strokeWidth_'.$plotVar,'0,0.5,1,1.5,2,2.5,3',$strokeWidth,1,$plotVar."_update_inp('strokeWidth')");
   $strokeWidthSel=getSelectFromArray('strokeWidth_'.$plotVar, array('0'=>0,'0.5'=>0.5,'1'=>1,'1.5'=>1.5,'2'=>2,'2.5'=>2.5,'3'=>3), $strokeWidth, 1, $plotVar."_update_inp('strokeWidth')");
    #legend position widget.
    $legendPos=getJSLink("{$plotVar}_legendLL","{$plotVar}_setLegendPos('LL')","&larrb;",'href_noline','Move legend full left').
        getJSLink("{$plotVar}_legendL","{$plotVar}_setLegendPos('L')","&larr;",'href_noline','Move legend left 10px').
        getJSLink("{$plotVar}_legendR","{$plotVar}_setLegendPos('R')","&rarr;",'href_noline','Move legend right 10px').
        getJSLink("{$plotVar}_legendRR","{$plotVar}_setLegendPos('RR')","&rarrb;",'href_noline','Move legend full right');
    $title="Add Title:".getStringInput('title_'.$plotVar,'',8,'',strip_tags($title),$plotVar."_update_inp('title')")." ";

    //Font size.. couldn't get builtin to work (messed up plot size)
    #$fontSize="Font size:".getIntInput('axisLabelFontSize_'.$plotVar,'',3,'','',$plotVar."_update_inp('axisLabelFontSize')").' ';
    $fsinc=getJSLink('',"{$plotVar}_incrementFontSize('+')","+");
    $fsdec=getJSLink('',"{$plotVar}_incrementFontSize('-')","-");
    $fontSize="{$fsdec}font{$fsinc}";

    $rollhelp=get_tooltip('?',"The data smoother does a rolling average of the prior x datapoints.  Note that the beginning and ends of series may not be smoothed due to lack of data points and there may be extraneous tail effects if the data series ends earlier than other plotted series.");
    $form="<div id='{$plotVar}_plotSettingsDiv'>

        ".getCheckBoxInput('fillGraph_'.$plotVar,'Fill graph',$fillGraph,$plotVar."_update_cb")."
       ".getCheckBoxInput('legend_'.$plotVar,'Show legend',$legend=='always',$plotVar."_update_cb")."$legendPos
        &nbsp;&nbsp;Point size:".getSelectFromList('pointSize_'.$plotVar,'0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5',$pointSize,1,$plotVar."_update_inp('pointSize')")."
        &nbsp;Line width:".$strokeWidthSel."
        &nbsp;&nbsp;Smoother(pts){$rollhelp}:".getIntInput('rollPeriod_'.$plotVar,'',3,'','',$plotVar."_update_inp('rollPeriod')")."
        &nbsp;&nbsp;Yaxis min:".getFloatInput('valueRangeMin_'.$plotVar,'','3','',$plotVar."_update_inp('valueRange')")."
        max:".getFloatInput('valueRangeMax_'.$plotVar,'','3','',$plotVar."_update_inp('valueRange')")."
        &nbsp;$toggle $fontSize &nbsp;$colors
        <span style='float:right;'>$title &nbsp; $optControl $save</span>
    </div>";
    //These functions could (should) all be in dbutils.js and pass plotVar as param.  I'm slowly moving over, but its
    //convienent to have them here during dev because errors don't affect production js code
    $html="$form<script>
        function {$plotVar}_updateOptions(opts){
            //fetch current legend pos so can reset afterwards.  updating options resets to orig pos instead of our nice one.
            w=dygraph_getLegendW('{$plotVar}');
            console.log(w);
            h=dygraph_getLegendH('{$plotVar}');
            $plotVar.updateOptions(opts,false);//redraw plot
            dygraph_setLegendW('{$plotVar}',w);
            dygraph_setLegendH('{$plotVar}',h);
        }
        function {$plotVar}_incrementFontSize(direction){
            var fs=parseInt($('.dygraph-axis-label').css('font-size'));
            var newfs='';
            if(direction=='+'){newfs=fs+1+'px';}
            else {newfs=fs-1+'px';}
            $('.dygraph-axis-label, .dygraph-ylabel').css('fontSize', newfs);
            //var opts={};
            //opts['axisLabelFontSize']=fs;
            //$plotVar.updateOptions(opts);//THIS hard sets to 14.  must be a bug.
        }
        function {$plotVar}_update_cb(id){//checkbox option handler
            var opt=id.split('_')[0];var opts={};
            if(opt=='legend'){opts[opt]=$('#'+id).prop('checked')?'always':'onmouseover';}
            else{opts[opt]=$('#'+id).prop('checked');}//get checked value
            {$plotVar}_updateOptions(opts);//redraw plot
        }
        function {$plotVar}_update_inp(opt){//input option handler
            var opts={};
            opts[opt]=$('#'+opt+'_{$plotVar}').val();//build id using plotVar
            if((opt=='strokeBorderWidth' ) && opts[opt]==0){opts[opt]=null;}
            if(opt=='title'){opts['legend']='always';}

            if(opt=='strokeWidth' && opts[opt]==0){
                opts[opt]=false;//This removes
                //opts['pointSize']=2;//make points more visible
                //$('#pointSize_{$plotVar}').val('2');
            }
            if(opt=='valueRange'){
                min=$('#valueRangeMin_{$plotVar}').val();
                max=$('#valueRangeMax_{$plotVar}').val();
                opts['valueRange']=[min,max];
            }
            {$plotVar}_updateOptions(opts);//redraw plot
        }
        function {$plotVar}_setColors(){
            var colors=$plotVar.getColors();
            colors.forEach(function (value, i) {
                //console.log('%d: %s', i, value);
                $('#{$plotVar}_'+i+'_color').spectrum('set', value);
            });
        }

        function {$plotVar}_setLegendPos(opt){//
            var legend=$('#{$plotVar}_div').find('.dygraph-legend');
            var w=parseInt(legend.css('left'));//Current legend position
            //figure out left border and optimal height
            var ll=$('.dygraph-axis-label-y').first().width()+10;//first y label width
            var hh=$('.dygraph-title').first().height()+10;//top title box
            legend.css('top',hh);
            //legend.css('width','auto');
            if(opt=='L'){
                legend.css('left',w-10);//Move left 10px
            }else if(opt=='LL'){//full left
                legend.css('left',ll);
            }else if(opt=='R'){
                legend.css('left',w+10);//Right 10px
            }else if(opt=='RR'){
                legend.css('left',$('#{$plotVar}_div').width()-legend.width()-10);
            }
        }
        ".delayedJS("{$plotVar}_setColors();{$plotVar}_setLegendPos('{$initLegendPos}');")."//Set the initial color state, after delay so plot is available.
        function {$plotVar}_update_color(i,series){//color option handler
            var colors=$plotVar.getColors();
            var opts={};
            var c=$('#{$plotVar}_'+i+'_color').val();
            colors[i]=c;
            opts['colors']=colors;
            //console.log(opts);
            $plotVar.updateOptions(opts,false);//redraw plot

        }
    </script>
    ";

    return $html;
}

?>
