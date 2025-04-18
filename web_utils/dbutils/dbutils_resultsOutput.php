<?php
#Various functions to output resultsets (table, graphs..)
function printDygraphPlot($a,$options=array(),$dev=False){
    /*Returns js for dygraph style plot
        $a is db result set from doquery()
            required COLS: x,series,y
            required SORT: x,series,y
            series is the label for series.   x is a datetime, y is value.

            if 'err' col is included and not -999.99, error bars are printed.  Logic currently looks at first row of first series to see if err
            col exists.  It sets err to 0 on all following datasets missing err col or with value =-999.99


    Any options can be passed in options array and will override $dfltOptions below.  Most are self explanitory, here are others:
    -showControls- whether to show the dynamic widgets or not
    -plotVar- pass a string variable name to use as js handle.
    -xIsDate=false if xaxis is a number
    -fillGraph - fills in area under plot line with color
    -strokeWidth - is the line width.  Pass 'false' for no lines
    -pointSize - is point size, pass drawPoints=false to hide.
    -legend - 'always' shows legend, 'onmouseover' only when mouse over, 'follow' to follow cursor
    -labelsDiv - put legend in external divid
    -xRangePad - points on either side of first/last data points to make sure visible.
    -connectSeparatedPoints draws line between missing points for series (when more than one series and one is missing data for a date)
    -staticHTML - wraps the js in an on load event listner so that it doesn't run until page is loaded.  This is needed when standalone html is created (no ajax to handle)
    -legendFormatter-side is formatted for longer list and should be used with a labelsDiv on side (see comparisons_funcs.php->plotComparison() for example),
        -default is overlaid on plot.  You can also pass a dynamic function for custom legend formatter . See printDygraphPlot_legendFormatter_default() for example.  But I think it would be best to add a new keyword (like side), create a function like others and then add below to legFormatter so that you can pass the plotvar and options to do toggling.

    -horzLines is an array of line arrays like this for 2 lines:
        $l=array();
        $l[]=array("color"=>'green',"y"=>$targ,"lineWidth"=>".5");
        $l[]=array("color"=>'green',"y"=>-$targ,"lineWidth"=>".5");
        $plotSettings['horzLines']=$l;
    -vertLines is an array of line arrays like this for 1 line:
        $plotSettings['vertLines']=array(array("color"=>'black',"x"=>'2010-02-01',"lineWidth"=>"5"));
        -optControl can be anything the caller wants to pass.  It gets put right next to the save btn.  Current use case is a share/email link for icp.
    -seriesOpts is an array of per series options like this:
        $plotSettings['seriesOpts']=array('2:CSIRO flask'=>array('strokeWidth'=>3));
    */

    $height="95%";$width="95%";
    $dfltOptions=array("plotVar"=>uniqid('dgplt_'),"xIsDate"=>true,'drawPoints'=>true,'fillGraph'=>false,
        'connectSeparatedPoints'=>true,'staticHTML'=>false,'drawGapEdgePoints'=>true,'stackedGraph'=>false,
        'pointSize'=>1.5,'strokeWidth'=>1,'strokeBorderWidth'=>null,'legend'=>'always','title'=>'',
        'rollPeriod'=>1,'showControls'=>true,'optControl'=>'','labelsDiv'=>'','xRangePad'=>10,
        'legendFormatter'=>'default','legendSide'=>'left','horzLines'=>array(),
        'vertLines'=>array(),'seriesOpts'=>array(),'ylabel'=>'','xlabel'=>'',
    );
        #note legend set to onmouseover causes weird issues when title is added
    $noPassOptions=array('plotVar','xIsDate','showControls','staticHTML','optControl','legendFormatter','legendSide','horzLines','vertLines','seriesOpts');//Options that don't get automatically passed to dygraph
    foreach($options as $key=>$val){$dfltOptions[$key]=$val;}

    if($a){
        $plotVar=$dfltOptions['plotVar'];$xIsDate=$dfltOptions['xIsDate'];
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
            $item=($xIsDate)?"[".getJSTimestamp($x,false).",":"[$x,";#dates need date obj creator
            $item.=implode(',',$vals)."],";#comma deliminate values()
            $json.=$item;
            if(isset($dups[$x])){#one or more entries with same time, add in with a pad of 10 microsecond to separate. Same logic as above.
                $i=1;
                foreach($dups[$x] as $r){
                    $item=($xIsDate)?"[".getJSTimestamp($x,false,$i*10).",":"[$x,";#dates need date obj creator, pad by 10+ microsecond
                    $item.=implode(',',$r)."],";#comma deliminate values()
                    $json.=$item;
                    $i++;
                }

            }
        }
        $json="[".substr($json,0,-1)."]";#strip trailing ,
        array_unshift($series,"X");#needed by options
        $opts="{labels: ".arrayToJSON($series);
        foreach($dfltOptions as $key=>$val){if(!in_array($key,$noPassOptions))$opts.=",$key:".boolstr($val);}#Note some of these aren't used by dygraph (like staticHTML) (noPassOptions)

        #Legend formatter.
        $legFormatter=$dfltOptions['legendFormatter'];
        if($dfltOptions['legendFormatter']=='side')
            $legFormatter=printDygraphPlot_legendFormatter_sideJS($plotVar,$dfltOptions);
        elseif($dfltOptions['legendFormatter']=='default')
            $legFormatter=printDygraphPlot_legendFormatter_default($plotVar,$dfltOptions);


        $horzLines='';
        if(isset($options["horzLines"]) && $options["horzLines"]){
            #add in calls to set horizontal lines.
            $x1=$a[0]['x'];
            $x2=$a[count($a)-1]['x'];
            if($xIsDate){
                $x1=getJSTimestamp($x1,false);
                $x2=getJSTimestamp($x2,false);
            }
            foreach($options["horzLines"] as $row){#$y=>$color){
                $y=$row['y'];$lineWidth=$row['lineWidth'];$color=$row['color'];
                $horzLines.="dygraph_horzLine(ctx,area,dygraph,$x1,$x2,$y,'$color',$lineWidth);";
            }
        }
        #dygraph_vertLine
        $vertLines='';
        if(isset($options["vertLines"]) && $options["vertLines"]){
            #add in calls to set vert lines.dygraph_vertLine(ctx,area,dygraph,y1,y2,x,color,lineWidth){
            $ys=arrayFromCol($a,'y');
            $y1=min($ys);
            $y2=max($ys);
            #var_dump($options["vertLines"]);
            foreach($options["vertLines"] as $row){#$y=>$color){
                $x=$row['x'];$lineWidth=$row['lineWidth'];$color=$row['color'];
                $vertLines.="dygraph_vertLine(ctx,area,dygraph,$y1,$y2,".getJSTimestamp($x).",'$color',$lineWidth);";
            }
        }
        $border="underlayCallback: function(ctx, area, dygraph) {
                         ctx.strokeStyle = 'black';
                         ctx.strokeRect(area.x, area.y, area.w, area.h);
                         $horzLines;
                         $vertLines;
                     }";
        $seriesOptions="";
        if(isset($options['seriesOpts']) && $options['seriesOpts']){
            $seriesOptions="series: ".arrayToJSON($options['seriesOpts'],true,'plotter').",";
            #foreach($options['seriesOpts'] as $k=>$v){
            #    appendToList2($seriesOptions,"'$k':$v");
            #}
            #$seriesOptions="series: {".$seriesOptions."},";
            #$seriesOptions="series: {'1:NOAA flask - 2:CSIRO flask_curve':{'plotter': smoothPlotter}},";
        }
        $opts.=",labelsUTC: true,$border,legendFormatter:$legFormatter,$seriesOptions plugins:[dygraphDoubleClickZoomOutPlugin]";//Handles missing series data for a date.  see dbutils.js->dygraphLegendFormatter()
        #$opts.=",showRoller:true,rollPeriod:60";#,valueRange:[414,416]
        #$opts.=",series:{'".$series[1]."':{strokeWidth:3}}";
        $opts.="}";
        if($dev){
            $plotSettings=($static || !$dfltOptions['showControls'])?'':dygraphSettingsDiv2($plotVar,$dfltOptions,$series);#widget to manipulate plot, skip on static so we don't need to link jquery
        }else{
            $plotSettings=($static || !$dfltOptions['showControls'])?'':dygraphSettingsDiv($plotVar,$dfltOptions,$series);#widget to manipulate plot, skip on static so we don't need to link jquery
        }
        $plot="var opts=$opts;\nvar data=$json;\n var $plotVar=new Dygraph(document.getElementById(\"$divID\"),data,opts);";
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
        #I think this works.. put in a table with plot max'd for slop.  It's not perfect (doesn't reflow on small resize), but handles initial plot when settings reflow
        $html="<table style='width:100%;height:100%'>
            <tr><td style='width:100%;height:100%'>
                <div id='$divID' style='width:99%;height:99%;border:thin silver solid;'></div>
            </td></tr>
            <tr><td>$plotSettings</td></tr>
            </table>
            <script>$plot</script>";


    }else $html='No Data';

    return $html;
}
function printDygraphPlot_legendFormatter_sideJS($plotVar,$options){
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
function printDygraphPlot_legendFormatter_default($plotVar,$options){
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



function dygraphSettingsDiv($plotVar,$options,$series){#getStringInput($id,$val,$size='12',$class='',$placeholder=''){
    /*returns a settings widget to edit current plot.
     Be careful of various states of plotVar.  String in php , var in js.  */

    extract($options);//bring all into scope
    #".getCheckBoxInput('drawPoints_'.$plotVar,'Draw points',$drawPoints,$plotVar."_update_cb")."
    #".getCheckBoxInput('connectSeparatedPoints_'.$plotVar,'Connect separated points',$connectSeparatedPoints,$plotVar."_update_cb")."
    # ".getCheckBoxInput('drawGapEdgePoints_'.$plotVar,'Draw edge points',$drawGapEdgePoints,$plotVar."_update_cb")."
    $print=printDivButton('Print',$plotVar."_div",false);
    $print='';//Not really needed and we're space constrained
    $save=saveDivButton('Save',$plotVar."_div",'plot.png',false);
    #toggle plots
    $t=array_shift($series);$toggle='';//Remove the X first element
    if(count($series)>1){
        $toggle="Toggle ";
        foreach($series as $i=>$sn){$toggle.="<span class='spanbtn' onclick='dygraph_toggleSeriesVisibility(\"${plotVar}\",$i)'><span>".($i+1)."</span></span> ";}
    }
    ###TAKING out toggle for now, it's in the legend
    $toggle='';

    #line border doesn't work great.
    #Line border:".getSelectFromList('strokeBorderWidth_'.$plotVar,'0,.5,1,1.5,2',$strokeBorderWidth,0,$plotVar."_update_inp('strokeBorderWidth')")."
    $colors="";
    $initLegendPos=($options['legendSide']=='left')?"LL":"RR";
    $optControl=$options['optControl'];
    foreach($series as $i=>$sn){$colors.=getColorPicker($plotVar."_${i}_color","#f00","${plotVar}_color color_picker",$plotVar."_update_color($i,'$sn')");}
    $colors=toggleJquerySelector("#${plotVar}_color_picker_span",'Colors','hide','','',false)."<span id='${plotVar}_color_picker_span'>$colors</span>";
    #$strokeWidthSel=getSelectFromList('strokeWidth_'.$plotVar,'0,0.5,1,1.5,2,2.5,3',$strokeWidth,1,$plotVar."_update_inp('strokeWidth')");
   $strokeWidthSel=getSelectFromArray('strokeWidth_'.$plotVar, array('0'=>0,'0.5'=>0.5,'1'=>1,'1.5'=>1.5,'2'=>2,'2.5'=>2.5,'3'=>3), $strokeWidth, 1, $plotVar."_update_inp('strokeWidth')");
    #legend position widget.
    $legendPos=getJSLink("${plotVar}_legendLL","${plotVar}_setLegendPos('LL')","&larrb;",'href_noline','Move legend full left').
        getJSLink("${plotVar}_legendL","${plotVar}_setLegendPos('L')","&larr;",'href_noline','Move legend left 10px').
        getJSLink("${plotVar}_legendR","${plotVar}_setLegendPos('R')","&rarr;",'href_noline','Move legend right 10px').
        getJSLink("${plotVar}_legendRR","${plotVar}_setLegendPos('RR')","&rarrb;",'href_noline','Move legend full right');
    $title="Add Title:".getStringInput('title_'.$plotVar,'',8,'',strip_tags($title),$plotVar."_update_inp('title')")." ";

    //Font size.. couldn't get builtin to work (messed up plot size)
    #$fontSize="Font size:".getIntInput('axisLabelFontSize_'.$plotVar,'',3,'','',$plotVar."_update_inp('axisLabelFontSize')").' ';
    $fsinc=getJSLink('',"${plotVar}_incrementFontSize('+')","+");
    $fsdec=getJSLink('',"${plotVar}_incrementFontSize('-')","-");
    $fontSize="${fsdec}font${fsinc}";

    $rollhelp=get_tooltip('?',"The data smoother does a rolling average of the prior x datapoints.  Note that the beginning and ends of series may not be smoothed due to lack of data points and there may be extraneous tail effects if the data series ends earlier than other plotted series.");
    $form="<div id='${plotVar}_plotSettingsDiv'>

        ".getCheckBoxInput('fillGraph_'.$plotVar,'Fill graph',$fillGraph,$plotVar."_update_cb")."
       ".getCheckBoxInput('legend_'.$plotVar,'Show legend',$legend=='always',$plotVar."_update_cb")."$legendPos
        &nbsp;&nbsp;Point size:".getSelectFromList('pointSize_'.$plotVar,'0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5',$pointSize,1,$plotVar."_update_inp('pointSize')")."
        &nbsp;Line width:".$strokeWidthSel."
        &nbsp;&nbsp;Smoother(pts)${rollhelp}:".getIntInput('rollPeriod_'.$plotVar,'',3,'','',$plotVar."_update_inp('rollPeriod')")."
        &nbsp;&nbsp;Yaxis min:".getFloatInput('valueRangeMin_'.$plotVar,'','3','',$plotVar."_update_inp('valueRange')")."
        max:".getFloatInput('valueRangeMax_'.$plotVar,'','3','',$plotVar."_update_inp('valueRange')")."
        &nbsp;$toggle $fontSize &nbsp;$colors
        <span style='float:right;'>$title &nbsp; $optControl $save</span>
    </div>";
    //These functions could (should) all be in dbutils.js and pass plotVar as param.  I'm slowly moving over, but its
    //convienent to have them here during dev because errors don't affect production js code
    $html="$form<script>
        function ${plotVar}_updateOptions(opts){
            //fetch current legend pos so can reset afterwards.  updating options resets to orig pos instead of our nice one.
            w=dygraph_getLegendW('${plotVar}');
            console.log(w);
            h=dygraph_getLegendH('${plotVar}');
            $plotVar.updateOptions(opts,false);//redraw plot
            dygraph_setLegendW('${plotVar}',w);
            dygraph_setLegendH('${plotVar}',h);
        }
        function ${plotVar}_incrementFontSize(direction){
            var fs=parseInt($('.dygraph-axis-label').css('font-size'));
            var newfs='';
            if(direction=='+'){newfs=fs+1+'px';}
            else {newfs=fs-1+'px';}
            $('.dygraph-axis-label, .dygraph-ylabel').css('fontSize', newfs);
            //var opts={};
            //opts['axisLabelFontSize']=fs;
            //$plotVar.updateOptions(opts);//THIS hard sets to 14.  must be a bug.
        }
        function ${plotVar}_update_cb(id){//checkbox option handler
            var opt=id.split('_')[0];var opts={};
            if(opt=='legend'){opts[opt]=$('#'+id).prop('checked')?'always':'onmouseover';}
            else{opts[opt]=$('#'+id).prop('checked');}//get checked value
            ${plotVar}_updateOptions(opts);//redraw plot
        }
        function ${plotVar}_update_inp(opt){//input option handler
            var opts={};
            opts[opt]=$('#'+opt+'_${plotVar}').val();//build id using plotVar
            if((opt=='strokeBorderWidth' ) && opts[opt]==0){opts[opt]=null;}
            if(opt=='title'){opts['legend']='always';}

            if(opt=='strokeWidth' && opts[opt]==0){
                opts[opt]=false;//This removes
                //opts['pointSize']=2;//make points more visible
                //$('#pointSize_${plotVar}').val('2');
            }
            if(opt=='valueRange'){
                min=$('#valueRangeMin_${plotVar}').val();
                max=$('#valueRangeMax_${plotVar}').val();
                opts['valueRange']=[min,max];
            }
            ${plotVar}_updateOptions(opts);//redraw plot
        }
        function ${plotVar}_setColors(){
            var colors=$plotVar.getColors();
            colors.forEach(function (value, i) {
                //console.log('%d: %s', i, value);
                $('#${plotVar}_'+i+'_color').spectrum('set', value);
            });
        }

        function ${plotVar}_setLegendPos(opt){//
            var legend=$('#${plotVar}_div').find('.dygraph-legend');
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
                legend.css('left',$('#${plotVar}_div').width()-legend.width()-10);
            }
        }
        ".delayedJS("${plotVar}_setColors();${plotVar}_setLegendPos('${initLegendPos}');")."//Set the initial color state, after delay so plot is available.
        function ${plotVar}_update_color(i,series){//color option handler
            var colors=$plotVar.getColors();
            var opts={};
            var c=$('#${plotVar}_'+i+'_color').val();
            colors[i]=c;
            opts['colors']=colors;
            //console.log(opts);
            $plotVar.updateOptions(opts,false);//redraw plot

        }
    </script>
    ";

    return $html;
}
function printGraph($a,$divID="",$plotVar="",$clickFunction="",$hoverFunction="",$seriesOptions=array(),$options="",$autoAssignSeriesToNewYAxis=false,$selectToZoomX=false,$description='',$timePlot=true,$togglePlot=true,$markings='',$yopts='',$showLines=true,$showPoints=true,$xAutoScaleMargin=false,$pointSize=1,$fillPoints=false,$adjustableYAxis=false,$plotColors='',$legendDiv='',$showControlButtons=true){
    /*Returns html/js to print a plot of resultset $a.  Must call get_dbutilsHeaderIncludes or manually include jquery.flot.js
     *Also requires some version of jquery to be already linked.
     *
     *$a is standard result set from doquery with 3 required columns:
     *series (label string ex 'co2'), x (datetime), y (float)
     *and optional columns:
     *  end_point: (1/0) that if specified will stop a line in the series (for a gap).  Next result will start back up.
     *  series_color: can either be a number from 0 to number of series to specify a specific auto generated color
     *      or a rgb(n,n,n) color
     *  yaxis:(int default 0).  This value is for the whole series.  (only the first one in the series is actually read)
     *      if zero, all series are added to the same yaxis
     *      if>0, series is assigned to that yaxis
     *      if<0 series is automatically assigned a new yaxis
     *  highlightPoint:(int 0 (default) or 1) pass a value of 1 to highlight the point
     *  unc: if passed, then error bars are drawn
     *
     *If series starts with a '-', then we just print a thin line (no points) (overlay).
     *
     *result set must be ordered by series, x
     *
     *Ex select: select 'co2' as 'series', timestamp(date,time) as x, value as y from flask_data where parameter=1 and site_num=75 order by date,time
     *
     *Calling with just $a uses fairly good defaults, but you can customize with options:
     *
     *$divID: pass to specifiy what to call div.  Note! there is a bug below if the divID starts with a number (i think),
     *so if you pass a divID, prefix with chars like this:
     *$divID=uniqid("flotgraph_");
     *
     *$plotVar: pass a name to use for the plot variable if you want to be able to reference later (like to refresh or reload data).  If
     *blank, a random one is assigned.
     *
     *$clickFunction: pass a js function name to use as a call back when graph is clicked.  It will get parameters event,pos,item
     *$hoverFunction: same or pass 'default' to have '(series name) value' put into a message box below the graph.  If you include
     * a hoverLabel column, that text will get used.
     *
     *options paramters can customize the output.  See see flot doc for details (https://github.com/flot/flot/blob/master/API.md)

     *$seriesOptions is an array of  non default options for each flot series.  The series name is the key
     *and the value is a json string of options for that series.  Options must be in json format as flot expects.
     *We just append whatever is passed into the series object, so any valid options inside of a series object can go in here.
     *syntax is like:
     *$seriesOptions["co2"]= "lines: { show: true }, points: { show: true },yaxis:2";
     *
     *Not all series need a line.
     *
     *$options: can be any valid options to pass in flot's 3rd param (options param).
     *Can be defaults for all series or grid, whatever flot accepts.  Must be in json format.
     *We basically just wrap in {} and assign
     *passed options to a js variable and pass to flot.
     *ex: "series: { lines: { show: true }, points: { show: true }}"
     *to set default show=true for all series and points
     *
     *Note!  if options is passed, it overwrites the clickable:true and hoverable:true that get set when clickFunction or hoverFunction is
     *passed.  So if you pass options and want a click/hover function, you must set clickable:true and hoverable:true as appropriate in the
     *option array:
     *"series: { lines: { show: true }, points: { show: true }},xaxis:{mode:\"time\",timeformat:\"%Y/%m/%d\"}, grid:{clickable:true,hoverable:true}"
     *The passed function names are still bound to callbacks though.

     *Note by default xaxis is defined to be time based.  This can be overridden with custom options array though.
     *Set $timePlot=false if not using a time based x axis.
     *
     *$autoAssignSeriesToNewYAxis:if true, each series gets assigned to a new yaxis.  You can also specify this in the select by
     *including a yaxis col (-1 auto, 0 all to 1 yaxis, >0 assigned to specific access).
     *Default false assigns all to the same axis.
     *
     *$selectToZoomX: pass true to allow user to select a band on x axis to zoom.  Also adds a reset button.  If false, default is scroll wheel zoom and pan support.  Default may be better (its a pluggin I found)
     *
     *$description: if passed, will be displayed under plot (except when hover event uses it).
     *Note! don't pass double quotes (if you need to, you'll need to edit function below to escape them.)Don't pass user input
     *
     *$timePlot: (default true) true if a time based plot (below logic sets up date labels)
     *
     *$togglePlot: (default true) if more than one yaxis and true, then clicking the axis label toggles the plot on and off.
     *NOT TESTED yet.. should be close, but project I was adding to used custom options, so couldn't test easily.. I think
     *just the labels links need to be debugged.  (seems to work in dt review aircraft thing I was adding too..)
     *
     *$markings, if passed will draw lines on plot. (unless you override options, then you need to set.)
     *  in form like {yaxis: {from:5, to: 6}, color:\"rgb(16,177,10)\",lineWidth:2},{yaxis: {from:$i, to: $i}, color:\"$cColor\",lineWidth:$w}
     *  See docs for details
     *
     *$yopts, if passed are yaxis specific options like: "min:0,max:24".  This is available so you don't have to roll your own whole options block if you just want to set ticksize or min/max

     *$plotColors can be a string of colors to use on datasets like: "'#60FF65','#FF7B5A','#60FF65','#617BFF'"
        Defaults are used for unmatched datasets.

     $legendDiv can be passed to hold the legend, else it's in the plot.
     *Here's an ex for co2 and ch4 from MLO, pair averaged. Note requires jquery linked and then get_dbutilsHeaderIncludes() to link graphing lib
        bldsql_init();
        bldsql_from("flask_data_view v");
        bldsql_col("v.parameter as 'series'");
        bldsql_col("timestamp(v.ev_date,v.ev_time) as x");
        bldsql_col("avg(v.value) as y");
        bldsql_where("v.parameter_num in (1,2)");
        bldsql_where("v.site='mlo'");
        bldsql_where("v.ev_date>?",'2015-01-01');
        bldsql_groupby("v.parameter");
        bldsql_groupby("timestamp(ev_date,ev_time)");
        $seriesOptions['co2']="yaxis:2";
        $options="yaxes:[{},{position:\"right\"}]";
        echo "<div id='graphDiv' style='width:800px;height:500px;'>".printGraph(doquery())."</div>";

    The auto scaling on xaxis when in time mode doesn't always seem to work.  Pass a value in $xAutoScaleMargin to force a margin (like 0.1)

    $pointSize=1 by default, pass any number for radius size

    $fillPoints is false by default (points dipslayed as circle).  Pass true to have them filled in.
    if $adjustableYAxis, then a slider is added to adjust the y axis.
    NOTE! this doesn't work on all layouts (rgm index.php), so don't make it default true without testing!
     */
    $t1=microtime(true);
    $html="";
    $xmargin=($xAutoScaleMargin!==false)?",autoscaleMargin:$xAutoScaleMargin":"";

    if(!$divID)$divID=uniqid("flotgraph_");

    #Handy plot manipulation buttons (see below for when included)
    $savebtn=($showControlButtons)?"<div style='float:left;display:inline'>".saveDivButton("Save Plot Image","${divID}",'plot.png',true).' '.printDivButton("Print","${divID}").' '.toggleJquerySelector(".legend","Show legend","Hide legend")."</div>":"";

    $html=" <div id='${divID}_outer' name='${divID}_outer' style='width:100%;height:100%;min-height:50px;min-width:50px;text-align:center'>";
    if($adjustableYAxis)$html.="<table class='thinTable' style='width:99%;height:100%;'><tr><td align='right'><div id='$divID' style='width:100%;height:100%;'></div></td><td width='10px' align='left' valign='center'><div style='height:180px' id='${divID}_yrangeSlider'></td></tr></table>";
    else $html.="<div id='$divID' style='width:100%;height:100%;'></div>";
    #The save button seems so handy, I'm just going to include it unconditionally when either zoom or display is set (so formatting doesn't get screwed.  Actually, just the display for now.)
    if($description || $hoverFunction=='default')$html.="$savebtn<div id='${divID}_displayDiv' style='display: inline;border:thin outset grey;width:50%;min-width:50%;text-align:center;padding-left:5px;padding-right:5px;'>&nbsp;</div>";
    if($selectToZoomX){#Add zoom buttons, handlers and reset above div height to fit them.
        $html.="<div id='${divID}_zoomBtns' style='float:right;display:inline'>
                    Zoom <button id='${divID}_zoomOut' style='font-size: smaller;'>-</button>
                    <button id='${divID}_zoomIn' style='font-size: smaller;'>+</button>
                </div><script language='JavaScript'>
                    var buttonH=$(\"#${divID}_zoomBtns\").outerHeight();
                    var outerH=$(\"#${divID}_outer\").outerHeight();
                    $(\"#$divID\").height(outerH-buttonH);
                </script>";
    }
    $html.="</div>";
    #$html.=getJSButton("${divID}_printBtn","${divID}html2canvas","Print/Save");
    $plotVar=($plotVar)?$plotVar:$divID."_plotvar";
    $minX=false;$maxX=false;$setYRange=false;$minY=false;$maxY=false;$hasErrBars=false;
    if($a){
        #Loop through the result set to create each series.
        $seriesKey="firstloop";$dataObj="";$sObj="";$dataSet="";$highlights="";$highlightPoint=0;$hoverLabel="";$hoverLabelArr="";$hoverLabelArrEls="";$unc=false;
        $end_point=0;#note end_point may be overridden in below extract, this is default value if not in select.
        $series_color=0;#ditto
        $yaxis=0;#ditto
        $c=1;$seriesIndex=-1;$dataPointIndex=-1;#Series/DatapointIndex are zero based, so need to start -1 so first one is 0.
        foreach($a as $row){
            extract($row);
            $dataPointIndex++;$overLayPlot=false;
            if(substr($series,0,1)=='-'){
                #if series name startes with a - sign, we'll make it an overlay plot (no points, thin line)
                $series=substr($series,1);
                $overLayPlot=True;
            }
            if($seriesKey!=$series){
                $seriesIndex++;$dataPointIndex=0;#Series increments, dataPointIndex starts over for each series, starting at 0
                #New (or first) series, set it up.  If a new one, close off the previous before starting new one.
                $seriesKey=$series;
                #close previous and append to dataObj
                if($sObj)$dataObj=appendToList($dataObj,$sObj,",")."$dataSet]}";#Add comma if 2nd+,sObj,$dataSet, then close $data ], then close series }
                #if($sObj)appendToList2($dataObj,$sObj."$dataSet]}",",");#Add comma if 2nd+,sObj,$dataSet, then close $data ], then close series }

                #Start new series
                $sObj='{label:"'.$seriesKey.'",';
                #add options from select
                if($series_color)$sObj.="color:\"$series_color\",";
                if($yaxis>0)$sObj.="yaxis:$yaxis,";
                if($yaxis<0 || $autoAssignSeriesToNewYAxis){
                    #auto assign to a new axis
                    $sObj.="yaxis:$c,";
                    $c++;
                }
                if($unc!==false){
                    #add error bar logic
                    $sObj.=" points:{show:true, errorbars:'y', yerr:{show:true,upperCap:'-',lowerCap:'-'}},lines:{show:false},";
                    $setYRange=true;#Y range auto size doesn't work on the min (sets to zero) for some reason when this option is on.NOt sure if this works with multiple y axises
                    $hasErrBars=true;#so we can know whether to hide below..
                }
                if($overLayPlot){
                    $sObj.=" points:{show:false},lines:{show:true,lineWidth:.75},";
                }
                #See if any optional params were passed in call
                if(isset($seriesOptions[$seriesKey])){
                    $sObj.=$seriesOptions[$seriesKey].",";
                }
                #start the data array
                $sObj.='data:[';
                $dataSet="";
                #If tracking hoverlabels, add a new series array.
                if($hoverLabel)$hoverLabelArr.="${divID}_hoverLabelArr[$seriesIndex]=[];";
            }
            #append in the data points
            #first convert datetime to js time value
            if($timePlot)$x=strtotime($x)*1000;#if($timePlot)$x=strtotime($x." UTC")*1000;  UTC was causing issues because dateformat (for label display) changed to local time.  Hopefully setting to local initially will take care of it.
            $minX=($minX===false || ($x<$minX && $x>-999))?$x:$minX;#track the smallest/largest we've seen for zooming logic.
            $maxX=($maxX===false || $x>=$maxX)?$x:$maxX;
            $u=($unc===false)?0:$unc;
            $minY=($minY===false || ($y-$u)<$minY)?($y-$u):$minY;
            $maxY=($maxY===false || ($y+$u)>=$maxY)?($y+$u):$maxY;
            $errBarSize=($unc!==false)?",$unc":"";#Add in unc data if present
            #$dataSet=appendToList($dataSet,"[$x,$y${errBarSize}]",",");
            appendToList2($dataSet,"[$x,$y${errBarSize}]",",");
            if($end_point)$dataSet.=",[null,null]";#Add the terminator flag to stop drawing the line.
            #if($highlightPoint)$highlights=appendToList($highlights,'['.$seriesIndex.','.$dataPointIndex.']',",");
            if($highlightPoint)appendToList2($highlights,'['.$seriesIndex.','.$dataPointIndex.']',",");

            #If tracking hoverlabels, then set in datastructure.. indexed by series/datapoint
            if($hoverLabel)$hoverLabelArr.="${divID}_hoverLabelArr[$seriesIndex][$dataPointIndex]='$hoverLabel';";
        }
        $togglePlot=($togglePlot && ($seriesIndex>1 || $yaxis>0));#Are we allowing toggle logic?

        $dataObj=appendToList($dataObj,$sObj,",")." $dataSet]}";#Add comma if 2nd+,sObj,$dataSet, then close $data ], then close series }
        #slower?.. appendToList2($dataObj,$sObj." $dataSet]}",",");#Add comma if 2nd+,sObj,$dataSet, then close $data ], then close series }

        #We should how have 1+ series, wrap in array and set in var
        $js="var ${divID}_data=[$dataObj];";

        #Build up the options
        $js.="var ${divID}_options={";
        if($options)$js.=$options;#Use whatever was passed
        else{
            #build up a default set
            $t_showLines=($showLines)?"true":"false";
            $t_showPoints=($showPoints)?"true":"false";
            $pointSize=($showPoints && $pointSize!=1)?", radius:$pointSize":"";
            $pointFill=($showPoints && $fillPoints)?",fill:1,fillColor:false":"";
            $js.="lines:{ show: $t_showLines }, points: { show: $t_showPoints $pointSize $pointFill},";

            if($timePlot)$js.="xaxis:{mode:\"time\" $xmargin}";#,timeformat:\"%Y-%m-%d\"
            else $js.="xaxis:{}";
            if($setYRange){
                $ymin=$minY-(($maxY-$minY)*0.05);#5% of total range.
                $ymax=$maxY+(($maxY-$minY)*0.05);
                #$yopts=appendToList($yopts,"min:$ymin,max:$ymax",",");#add in a min if needed.
                appendToList2($yopts,"min:$ymin,max:$ymax",",");#add in a min if needed.
            }
            if($yopts)$js.=",yaxis:{ $yopts }";
            #Event handlers?
            $t="";
            if($clickFunction) $t="clickable:true";
            if($hoverFunction) $t=appendToList($t,"hoverable:true",",");
            #plot lines?
            if($markings){
                $markings="markings:[$markings]";
                #$t=appendToList($t,"$markings",",");
                appendToList2($t,"$markings",",");
            }
            if($t)$js.=",grid:{".$t."}";
            #Add clickable legend links if toggle mode on. NEEDS to be tested and debugged...
            $legendDiv=($legendDiv)?', placement: "outsideGrid", container: $("#'.$legendDiv.'")':"";
            if($togglePlot ) $js.=",legend: {
                                        labelFormatter: function(label, series){
                                          return '<a href=\"#\" onClick=\"togglePlot_${plotVar}(\''+label+'\'); return false;\">'+label+'</a>';
                                        }$legendDiv
                                    }";
            #$plotColors="'#4286f4','#FF7B5A','#60FF65','#617BFF'";
            if($plotColors)$js.=",colors:[$plotColors]";#ex:"'#60FF65','#FF7B5A','#60FF65','#617BFF'";
            if(!$selectToZoomX)$js.=",zoom: {interactive: true},pan: {interactive: true}";#Do mouse wheel and pan by default
        }
        $SelJS="";

        if($selectToZoomX){#Do all the js voodoo to make the select to zoom and zoom buttons work.
            $js.=",selection:{mode:\"x\"}";
            $SelJS="var ${divID}_lastMinX=$minX;
                    var ${divID}_lastMaxX=$maxX;
                    $(\"#$divID\").bind(\"plotselected\", function (event, ranges) {

                        $.each($plotVar.getXAxes(), function(_, axis) {
                            var opts = axis.options;
                            opts.min = ranges.xaxis.from;
                            opts.max = ranges.xaxis.to;
                            ${divID}_lastMinX=ranges.xaxis.from;//Track for below zoom buttons.
                            ${divID}_lastMaxX=ranges.xaxis.to;
                        });
                        $plotVar.setupGrid();
                        $plotVar.draw();
                        $plotVar.clearSelection();
                        });
                    $(\"#${divID}_zoomOut\").bind(\"click\").click(function () {
                        ${divID}_zoomPlotOut();
                    });
                    $(\"#${divID}_zoomIn\").bind(\"click\").click(function () {
                        ${divID}_zoomPlotIn();
                    });
                    //Wheel support was a little wonky (too fast),so I disabled for now..
                    //$(\"#$divID\").bind('mousewheel DOMMouseScroll', function(event){
                    //    if()
                    //    if (event.originalEvent.wheelDelta > 0 || event.originalEvent.detail < 0) {
                    //        // scroll up
                    //        ${divID}_zoomPlotOut();
                    //    }
                    //    else {
                    //        // scroll down
                    //        ${divID}_zoomPlotIn();
                    //    }
                    //});
                    function ${divID}_zoomPlotOut(){
                        $.each($plotVar.getXAxes(), function(_, axis) {
                            var opts = axis.options;
                            var step = ($maxX-($minX))/10;//10% per click
                            var newMin=${divID}_lastMinX-step;
                            if(newMin<$minX)newMin=$minX;
                            var newMax=${divID}_lastMaxX+step;
                            if(newMax>$maxX)newMax=$maxX;
                            opts.min = newMin;
                            opts.max = newMax;
                            ${divID}_lastMinX=newMin;
                            ${divID}_lastMaxX=newMax;
                        });
                        $plotVar.setupGrid();
                        $plotVar.draw();
                        $plotVar.clearSelection();
                    }
                    function ${divID}_zoomPlotIn(){
                        $.each($plotVar.getXAxes(), function(_, axis) {
                                var opts = axis.options;
                                var step = ($maxX-($minX))/10;
                                var mid = $minX+(($maxX-($minX))/2);
                                var midBand=1000;

                                var newMin=${divID}_lastMinX+step;
                                if(newMin>(mid-midBand))newMin=mid-midBand;
                                var newMax=${divID}_lastMaxX-step;
                                if(newMax<(mid+midBand))newMax=mid+midBand;
                                opts.min = newMin;
                                opts.max = newMax;
                                ${divID}_lastMinX=newMin;
                                ${divID}_lastMaxX=newMax;
                            });
                            $plotVar.setupGrid();
                            $plotVar.draw();
                            $plotVar.clearSelection();
                    }

                    ";
        }
        #close out
        $js.="};";

        $js.="var $plotVar=$.plot((\"#${divID}\"),${divID}_data,${divID}_options);";

        #Add adj yaxis
        if($adjustableYAxis){
            $js.="//Set up the slider widget to adjust the yaxis.
                var adjYAxisMin=${plotVar}.getAxes().yaxis.min;//Default vals from plot
                var adjYAxisMax=${plotVar}.getAxes().yaxis.max;
                $('#${divID}_yrangeSlider').slider({
                    range:true,
                    min:adjYAxisMin,
                    max:adjYAxisMax,
                    values:[adjYAxisMin,adjYAxisMax],
                    orientation:'vertical',
                    slide:function(event,ui){
                        //var options=${plotVar}.getOptions();
                        //options.yaxes[0].min=ui.values[0];
                        //options.yaxes[0].max=ui.values[1];
                        //${plotVar}.setupGrid();
                        //${plotVar}.draw();
						${divID}_adjY(ui.values[0],ui.values[1]);

                    }
                });
				function ${divID}_adjY(newMin,newMax){
					var options=${plotVar}.getOptions();
					options.yaxes[0].min=newMin;
					options.yaxes[0].max=newMax;
					${plotVar}.setupGrid();
					${plotVar}.draw();
				}
            ";
        }
        #Add alt hover array if needed/set
        if($hoverLabelArr)$js.="var ${divID}_hoverLabelArr=[];$hoverLabelArr";#create 2 d structure (filled above).

        #bind event handlers if needed.
        if($clickFunction)$js.="$(\"#${divID}\").bind(\"plotclick\",function (event,pos,item){ ${clickFunction}(event,pos,item);});";
        if($hoverFunction=='default'){#Puts a datapoint label in the little box below the plot.
            $js.="$(\"#${divID}\").bind(\"plothover\",function (event,pos,item){
                    $(\"#${divID}_displayDiv\").html(\"$description\");//Clear out or set passed display message
                        if (item) {";
            if($hoverLabelArr){#Labels passed from query, set into hoverLabelArr above.. just output directly.
                $js.="      var o=${divID}_hoverLabelArr[item.seriesIndex][item.dataIndex];";
            }else{#build up a 'date (series label): value' string
                #attempt to correct time zone offset from browser (really annoying)
                $js.="      //var userTZ = new Date();//user = the viewers browser
                            //userTZ = userTZ.getTimezoneOffset()*60*1000;
                            var time=new Date(item.datapoint[0]);
                            //var time=new Date.UTC(item.datapoint[0]);//+userTZ
                            var o=$.datepicker.formatDate('M d, yy',time);
                            o=\"<span>\"+o+\"</span>&nbsp;&nbsp;(\"+item.series.label+\"):<span style='font-weight: 600;'> \"+item.datapoint[1]+\"</span>\";
                ";
            }
            $js.="
                            $(\"#${divID}_displayDiv\").html(o);
                        }
                    });
                $(\"#${divID}_displayDiv\").html(\"$description\");";
        }
        elseif($hoverFunction=='tooltip')$js.="$(\"#${divID}\").bind(\"plothover\",function (event,pos,item){ onPrintGraphHoverShowToolTip(event,pos,item);});";
        elseif($hoverFunction)$js.="$(\"#${divID}\").bind(\"plothover\",function (event,pos,item){ ${hoverFunction}(event,pos,item);});";

        #Add highlight logic if needed.
        if($highlights){
                $js.="function ${divID}_highlightPoints(plotVar,arr) {
                    for (var i=0, len=arr.length; i<len;i++){
                        var a=arr[i];
                        //console.log(a);
                        plotVar.highlight(a[0],a[1]);
                    }

                }
                var ${divID}_highlights=[$highlights];
                ${divID}_highlightPoints($plotVar,${divID}_highlights);";

        }

        #Toggle plots?
        $showLinesBool=($showLines)?"(1==1)":"(1==0)";
        $showPointsBool=($showPoints)?"(1==1)":"(1==0)";
        if($togglePlot){
            #These should be refactored.. I think this was all experimental and not fully set yet, but adding in errorbar support too.12/17
            $errBarsShow=($hasErrBars)?"someData[seriesIdx].points.yerr['show']=true;":"";
            $errBarsHideI=($hasErrBars)?"someData[i].points.yerr['show']=false;":"";
            $errBarsHide=($hasErrBars)?"someData[seriesIdx].points.yerr['show']=false;":"";
            $errBarsHideShow=($hasErrBars)?"someData[seriesIdx].points.yerr['show']= !someData[seriesIdx].points.yerr['show'];":"";
            $js.="
            var togglePlot_${plotVar} = function(label)
            { //console.log(label);
              var seriesIdx=-1;
              var someData = ${plotVar}.getData();
              for(var i = 0, len=someData.length;i<len;i++){
                //console.log(someData[i]);
                if(someData[i].label==label){seriesIdx=i;}
              }

              someData[seriesIdx].points.show = (!someData[seriesIdx].points.show && $showPointsBool);
              someData[seriesIdx].lines.show=(!someData[seriesIdx].lines.show && $showLinesBool);
              $errBarsHideShow
              ${plotVar}.setData(someData);
              ${plotVar}.draw();
            };";
            /*This was a little too complicated and non-intuitive
             *$js.="var togglePlot_${plotVar} = function(label)
            { //console.log(label);
              var seriesIdx=-1;
              var someData = ${plotVar}.getData();
              var anyHidden=false;
              var clickedIsHidden=false;
              for(var i = 0, len=someData.length;i<len;i++){
                //console.log(someData[i]);
                if(someData[i].label==label){
                    seriesIdx=i;
                    clickedIsHidden=(!someData[i].points.show);
                }else{
                    if(!someData[i].points.show){anyHidden=true;}
                }
              }

              someData[seriesIdx].points.show = true;
              someData[seriesIdx].lines.show=true;
              $errBarsShow
              if(!anyHidden){
                console.log('hiding all others');
                for(var i = 0, len=someData.length;i<len;i++){
                    if(i!=seriesIdx){
                        someData[i].points.show = false;
                        someData[i].lines.show=false;
                        $errBarsHideI
                    }
                }
              }else{
                if(!clickedIsHidden){
                    console.log('Clicked not hidden, hide now.');
                    someData[seriesIdx].points.show = false;
                    someData[seriesIdx].lines.show=false;
                    $errBarsHide
                }
              }
              ${plotVar}.setData(someData);
              ${plotVar}.draw();
            };";*/
        }
        $js2=" function ${divID}html2canvas(){
                    html2canvas($('#${divID}').get(0)).then(function(canvas) {
                        image = canvas.toDataURL('image/png');
                        document.location.href=image;

                    });
                }";
        $html.="<script language='JavaScript'>$js $SelJS $js2</script>";
    }else $html.="No data to graph.";
    $t2=microtime(true);
    #var_dump($t2-$t1);
    return $html;
}



function downloadCSV($a,$fileName='data.csv',$delimiter=',',$enclosure='"'){
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
function downloadFile($fileName='saved.txt',$content=""){
    #Sends $content to browser as a file
   #See downloadCSVLink() in htmlutils for how to set up a link.
    header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
    header('Content-Description: File Transfer');
    header("Content-type: text/csv; charset=utf-8");
    header("Content-Disposition: attachment; filename={$fileName}");
    header("Expires: 0");
    header("Pragma: public");

    $fh = @fopen( 'php://output', 'w' );

    fwrite($fh,$content);    //Output

    fclose($fh);    // Close the file
    // Make sure nothing else is sent, our file is done
    exit;
}
function printTableW($a,$opts=array()){
    /*Wrapper for printTable for optional opts. See doc for printTable()*/
    $fullOpts=array(
    'onClick'=>"",
    'leftHiddenCols'=>0,
    'class'=>'',
    'width'=>"",
    'height'=>"",
    'divID'=>"",
    'selectedRowKey'=>'',
    'floatHeader'=>true,
    'editableField'=>'',
    'passRowIDToOnClick'=>false,
    'editFieldOnClick'=>''
    );
    foreach($opts as $key=>$val){$fullOpts[$key]=$val;}#Overwrite defaults
    extract($fullOpts);
    return printTable($a,$onClick,$leftHiddenCols,$class,$width,$height,$divID,$selectedRowKey,$floatHeader,$editableField,$passRowIDToOnClick,$editFieldOnClick);
}
function highlightResultSearch($a,$searchTerm){
    #highlight matched text in dbquery result $a.  For use in printTable.
    if($searchTerm=='')return $a;
    $b=array();
    foreach($a as $row){
        $nr=array();
        foreach($row as $k=>$f){
            if($k=='onClickParam' || $k=='rowClass')$nr[$k]=$f;#skip hidden columns
            else $nr[$k]=highlightSearchPhrase($f,$searchTerm);
        }
        $b[]=$nr;
    }
    #var_dump($b);
    return $b;
}

function printTable($a,$onClick="",$leftHiddenCols=0, $class='',$width="",$height="",$divID="", $selectedRowKey='',$floatHeader=true,$editableField='',$passRowIDToOnClick=false,$editFieldOnClick=''){
$floatHeader=false;#testing
    /*Prints results set from doquery. If you echo below getHTMLHeaderIncludes in the
     *html head section, it will look a little prettier.

     *If $onClick js function name is passed, you must also select a column called 'onClickParam'
     *that contains javascript params to pass to the click method
     *ie,
     *If you have a js:
     *  function loadDetail(rowNum){...}
     *you would include in the query as first col:
     *  bldsql_col("table.num as onClickParam");
     *and then when calling this:
     *  printTable($a,"loadDetail",1)
     *which would hide the first col and set this as the row's click event:
     *  onClick='javascript:loadDetail(".$onClickParams{$i}.")' or similar.
     *You can do multi params too, like:
        bldsql_col("concat(v.period_num,',',v.grant_num) as onClickParam");
     * ?Not sure of this example, (conceptually works, but don't think the text is correct)... bldsql_col(+",'"+table.name as onClickParam);
     *which will pass something like
     *  loadDetail(3,5)
     *Note, onClickParam is just passed straight through, so you need to include any needed quotes and commas.
     *Use single quotes like this awkward passed string:
     *  bldsql_col("concat(4,\",'\",'fred',\"'\")")
     *which results in
     *  4,'fred'
     *
     * js can be something like:
        function loadDetail(rowNum){
            //Loads selected row
            var formData=$("#search_form").serialize();//Grab current filters incase needed.
            ajax_post("loadDetail",formData+"&inst_num="+rowNum,"fixedHeightContentDiv");
        }

     *If width/height passed, this will put into a scrolling div.  Must pass with units (250px or 100%)
     *
     *  $leftHiddenCols is number of leading columns to hide.
     *  $class is optional styling class to use.  Defaults to dbutils (fairly basic) if blank.  Can pass jquery if jquery-ui is already linked.
     *
     *$divID is actually mis-named (from habit), if passed, it is the table id.
     *If $divID is not passed, a unique id is used.  If passed, you should probably use a uniqid() to avoid potential issues with binding.
     *
     *If an onClick and divID is passed then a refresh function is added:
     *reclick_${divID}() which will reselect the current selection, firing the click event.  This can be used to reload
     *the selection.
     *
     *If $selectedRowKey and $onClick is passed, then the row with matching onClickParam is 'clicked'
     *
     *You can also optionally include col 'rowClass' in the output.  If present and set, that class will be applied to the row.
     *
     *if floatHeader=true, we do some voodoo to float the table header when scrolling.
     *
     *If $editableField is specified, col with that name is turned into an input and submited to switch with doWhat=$onClick
        and new value in http field ptef_val and primary key in ptef_pk.
     * caller must provide doWhat in the onClick and primary key in selected column called onClickParam.
     * doWhat (onClick) function must return the successfully submitted value or error message.

     (because need came up)you can alternately provide editFieldOnClick, which will be used instead of onClick just for this column.  This lets you
     * still be able to have a row level onClick action

     * be carefule with col name (no spaces, no special html chars or probably even java.. single word or _ for now.)
     * note reedits don't currently work (see below for js hack to prevent)
     # ex:
     (list func)
     bldsql_col("concat('$',format(s.sal,0)) as 'Sal_Ben'");
     return printTable(doquery(),'emp_editSalary',1,'','600px','','','',true,'Sal_Ben');

     (in switch.php)
      case "emp_editSalary":
        $html=emp_editSalary();

     (in emp_editSalary() func)
        $pk=getHTTPVar("ptef_pk",false,VAL_STRING);#can be sal pk or overloaded emp_num_7_2019 (emp_num_[#]_[fy])
        $newVal=getHTTPVar("ptef_val",false,VAL_FORMATTED_INT);
        ...update row...
        $js="<script>var trow = $('#${inpID}').closest('tr');trow.prop('onclick', null);trow.click(function(){alert('You must refresh the page to edit this row.');});</script>";#hack to avoid re-edits
        $val=doquery("select format(sal,0) from sals where num=?",0,array($pk));
        return $val.$js;
    *if passRowIDToOnClick then an id is assigned to row and it is passed to the onclick function.
     **/
    $mouseOver="";
    $selectedIndex=false;

    $class=($class)?"dbutils $class":"dbutils";
    $selectable=($onClick)?"dbutils_selectable":"";
    $tableClass="class='$class sortable $selectable'";
    #$scrollCSS=($tableHeight && false)?"style='height:$tableHeight; overflow:auto;'":"";
    if($a){
        $uniqueID=($divID)?$divID:uniqid("dbutils_printTable");
        $html="";

        if($width || $height){
            $html.="<div style='overflow:auto;border:thin silver solid;";
            if($width)$html.="width: $width;";
            if($height)$html.="height: $height;";
            $html.="'>";
        }

        $html.="<table $tableClass id='$uniqueID' width='99%'><thead><tr>";#withd slightly smaller to accomodate the 'selected row wider p
        $i=1;
        $sortCounter=0;

        foreach($a as $row){
            //var_dump($a);
            $pk=(isset($row['onClickParam']))?$row['onClickParam']:false;
            #Header
            if($i==1){#Include a header row
                $j=1;
                foreach($row as $key=>$val){
                    if($j>$leftHiddenCols){#Skip any that should be hidden.
                        $editImg=($editableField && strcasecmp($key,$editableField)==0)?'&nbsp;&nbsp;<img style="border:1px solid blue;" src="/inc/dbutils/template/resources/write.jpeg" width="12" height="12">':"";#Assume dir structure.  This should be using path from dbutils though...
                        $editTitle=($editableField && $editableField==$key)?"Click field to edit":"";
                        $html.="<th title='$editTitle'><a href='#' onclick=\"ts_resortTable(this,$sortCounter,getElementById('$uniqueID'));return false;\">$key<span class='sortarrow'></span></a>$editImg</th>";
                        $sortCounter++;
                    }
                    $j++;
                }
                $html.="</tr></thead><tbody>";
            }

            #Table

            #see if a rowclass was specified.
            $rowClass="";
            if(isset($row['rowClass']))$rowClass=$row['rowClass'];
            $rowClass=($rowClass)?"class='$rowClass'":"";
            $uRowID='';$uRowID_param='';
            if($passRowIDToOnClick){
                $uRowkey=uniqid("dbut_row_");
                $uRowID="id='$uRowkey'";
                $uRowID_param=",'$uRowkey'";
            }else{
                $uRowID='';
                $uRowID_param='';
            }
            #If an onClick was passed, include it in the TR, unless we're doing a editable field, then setup the field level handler.
            if($onClick && !$editFieldOnClick){
                if (isset($row['onClickParam'])){

                    if($editableField)$html.="<tr $rowClass onClick=\"JavaScript:editablePrintTableField('${key}','${pk}','${onClick}');\" >";
                    else $html.="<tr $uRowID $rowClass onClick=\"JavaScript:$onClick(".$row['onClickParam']."$uRowID_param);\" >";
                    #Nope, nope, nope.  autoselecting caused infinite loop issues on some applications (drierhist), not sure why but turning off for now.  Was being used by instrument manager
                    #if(!$selectedRowKey && count($a)==1)$selectedRowKey=$row['onClickParam'];#if only one, preselect it.

                    if($selectedRowKey && !$selectedIndex)$selectedIndex=($row['onClickParam']==$selectedRowKey)?$i:false;#Mark the row with passed key if needed.

                }else{var_dump("Error; missing onClickParam column in query");exit();}#Just for developer reminder.
            }else $html.="<tr $rowClass>";
            $j=1;

            #Output the content
            foreach($row as $key=>$val){
                if($j>$leftHiddenCols){#Skip any that should be hidden.
                    $js='';
                    #if special edit field onclick passed, we need to set up click handlers for every td
                    if($editFieldOnClick){
                        if(strcasecmp($key,$editableField)==0)$js="onClick=\"editablePrintTableField('${key}','${pk}','${editFieldOnClick}');\"";
                        else $js="onClick=\"$onClick(".$row['onClickParam']."$uRowID_param);\"";
                    }
                    if($editableField && strcasecmp($key,$editableField)==0 ){#add editable field LogicException
                        if($onClick && $pk){
                            $id="${key}_input_${pk}";
                            $disp="${key}_display_div_${pk}";

                            $html.="<td $js class='editableTableTD'><input type='text' id='${id}' name='${id}' style='display:none' value='$val' size='5'><div id='${disp}'>$val</div></td>";
                        }else{var_dump("Error; missing onClick or onClickParam");exit();}
                    }else $html.="<td $js>$val</td>";
                }
                $j++;
            }
            $html.="</tr>";
            $i++;
        }
        $html.="</tbody></table>";
        if($width||$height)$html.="</div>";

        #Add a reclick function
        $reclick="";
        if($onClick && $divID){
            $reclick="function reclick_${divID}(){
                        //reclicks currently selected row
                        $(\"#${uniqueID} tr.dbutils_selectedRow\").click();
                    }";
        }
        #Select a row if passed.
        $preSelect='';
        if($selectedIndex){
            $preSelect="$(\"#${uniqueID} tr:nth-child($selectedIndex)\").click();";
        }
        #Add row selection highlighting if needed.
        if($onClick && !$editableField)$html.="<script language='JavaScript'>
                $(\"#${uniqueID} tbody\").on(\"click\", \"tr\", function(event) {
                    $(\"#${uniqueID} tr.dbutils_selectedRow\").removeClass(\"dbutils_selectedRow\");//Unselect any previous selection.
                    $(this).addClass(\"dbutils_selectedRow\");//Select current row
                });
                $reclick
                $preSelect
        </script>";
        if($floatHeader){#Add in the foating header for when tabe scrolls.  note we set zIndex explicitly (and somewhat arbitrarily) because
        #some of the jquery ui elements (pop up dialog boxes) had a z index lower (101 vs dflt 1001 for floathead).  Setting this one to 99
        #seemed to fix the issue (popup was behind this header row.).
        #Also note; if you move content or cause it to re-layout (such that col widths change), you will need to reflow this object so that the cells align.
        #  $('#outputDataTable').floatThead('reflow');
            $html.='
            <script language="JavaScript">
                $(function(){
                    var t_table = $("#'.$uniqueID.'");
                    t_table.floatThead({
                        position: "fixed",
                        scrollContainer: true,
                        zIndex: 99
                    });
                });
            </script>';
        }
    }else $html= "No results";

    return $html;
}


function printPieChart($a,$description,$width,$height,$legendToRight=false,$includeNumOnHover=true,$plotColors=''){
    /*$a is the result of a group by query that results in label:num results like:
     *select program as 'label',count(*) as 'num' from flask_data_view group by program
     *
     *$description will print below
     *width & height are css values (200px or 100%)
     *Note call to get_dbutilsHeaderIncludes must pass true for 2nd param.
     *$plotColors can be a string of colors to use on datasets like: "'#60FF65','#FF7B5A','#60FF65','#617BFF'"
        Defaults are used for unmatched datasets.
     */
    $html="Not enough data";
    if($a){
        $plotDivID=uniqid("flotpie_");
        $dataSet="";
        foreach($a as $row){
            extract($row);
            $dataSet=appendToList($dataSet,"{label: \"$label\", data: $num}");
        }
        $legdendContainer=($legendToRight)?",container:$('#${plotDivID}_legend')":"";
        $dataSet="var ${plotDivID}_dataSet=[$dataSet];";
        $plotColors=($plotColors)?"colors:[$plotColors],":"";
        $options="var ${plotDivID}_options={
            series:{
                pie:{
                    show:true
                }
            },
            legend:{
                show:true
                $legdendContainer
            },
            $plotColors
            grid:{
                hoverable:true
            }
        };";
        $js="$dataSet $options $.plot($(\"#${plotDivID}\"),${plotDivID}_dataSet,${plotDivID}_options);";

        #if($clickFunction)$js.="$(\"#${divID}\").bind(\"plotclick\",function (event,pos,item){ ${clickFunction}(event,pos,item);});";
        #Add hover function
        $n=($includeNumOnHover)?" \"+n+\"":"";
        $js.="$(\"#${plotDivID}\").bind(\"plothover\",function (event,pos,item){
            $(\"#${plotDivID}_text\").html(\"$description\");//Clear out or set passed display message
                if (item) {
                   var percent = parseFloat(item.series.percent).toFixed(2);
                   var n=item.series.data[0][1];
                   n=formatNumber(n);
                   var o=item.series.label+\":<span style='font-weight: 600;'>$n (\"+percent+\"%)</span>\";
                   $(\"#${plotDivID}_text\").html(o);
                   //console.log(item.series.data[0][1]);
               }
            });
        $(\"#${plotDivID}_text\").html(\"$description\");";
        if($legendToRight){
            $legHeight=intval($height*.7);
            $html="<table><tr><td><div id='$plotDivID' style='float:left;width:$width;height:$height'></div></td><td valign='top'><div id='${plotDivID}_legend' class='scrolling border' style='height:${legHeight}px;'></div></td></tr><tr><td colspan='2'><div id='${plotDivID}_text' style='display: inline;border:thin outset grey;width:50%;min-width:50%;text-align:center;padding-left:5px;padding-right:5px;'>&nbsp;</div></td></tr></table>";
        }else{
            $html="<div id='$plotDivID' style='width:$width;height:$height'></div><div id='${plotDivID}_text' style='display: inline;border:thin outset grey;width:50%;min-width:50%;text-align:center;padding-left:5px;padding-right:5px;'>&nbsp;</div>";
        }

        $html.="<script language='JavaScript'>$js</script>";
    }
    return $html;
}
function printStackedBarChart($a,$description,$width,$height,$type,$showControlButtons=true,$legendDiv=''){
    /*$a is the result of a group by query that results in label:num results like:
     *select series, x, y (see ex below)
     *include xlabel col for custom tick labels corresponding to x values.
     *
     *Must be grouped (optional) and ordered by series,x
     *
     *$description will print below
     *width & height are css values (200px or 100%)
     *showcontrolbuttons are the save,print,show lengend buttons
     *legend div puts legend there
     *$type is the aggregating type (x axis).  valid values are currently:
     *  'year' for yearly.
     *  'month' for monthly
     #  'day'
     *  'weekday_hour' for hourly over 2 week (query must restrict data as appropriate, xlabels will only be weekdays/hrs).  This one is very customized for a specific use (recent ccgg results)
     *  '[series label]' for any non time based series
     *Note call to get_dbutilsHeaderIncludes must pass true for 2nd param.
     *ex:
     *$sql="SELECT  order_status as 'series', CAST(DATE_FORMAT(due_date ,'%Y-%m-01') as DATE) as 'x', count(*) as 'y'
            FROM refgas_orders.rgm_order_view
            where  datediff(due_date,now())<180
                and due_date>=(select min(due_date) from refgas_orders.rgm_order_view where order_status_num not in (5,7))
            group by order_status,CAST(DATE_FORMAT(due_date ,'%Y-%m-01') as DATE)
            order by order_status,CAST(DATE_FORMAT(due_date ,'%Y-%m-01') as DATE)";
    $ordDue=printStackedBarChart(doquery($sql),"Order status by due date",'400px','300px','month');
    or
    #Calibrations
    bldsql_init();
    bldsql_from("rgm_calrequest_view v");
    bldsql_from("calservice c");
    bldsql_where("c.num=v.calservice_num");
    bldsql_col("v.status as 'series'");
    bldsql_col("v.calservice_num as 'x'");
    bldsql_col("count(v.request_num) as 'y'");
    bldsql_col("c.abbr as xlabel");
    bldsql_where("v.order_status_num not in (5,7)");
    bldsql_groupby("v.status");
    bldsql_groupby("v.calservice_num");
    bldsql_orderby("v.status");
    bldsql_orderby("v.calservice_num");
    $calStatus=printStackedBarChart(doquery(),"Open order cal requests",'400px','300px','Request type');

     */
    $html="Not enough data";
    $id=uniqid("stackedBarChart_");
    $xaxis="";$timePlot=true;$ticks="";$seriesColor="";

    if($a){
        if(isset($a[0]['xlabel'])){
            #Creat custom x tick labels.
            $labels=arrayFromCol($a,'xlabel');
            $xs=arrayFromCol($a,'x');
            foreach($xs as $i=>$x){
                $label=$labels[$i];
                $ticks=appendToList($ticks,"[$x,'$label']");
            }
            $ticks="ticks: [$ticks],";
        }
    }
    if($type=="month"){#\"%m/%y\"
        $xaxis="mode:\"time\",
            timeformat:\"%m\",
            tickSize:[1,\"month\"],
            tickLength:0,$ticks
            axisLabel: 'Month'";#Default monthly
            $barWidth="1000*60*60*24*15";#1/2 month (in milliseconds).
    }elseif($type=="year"){
        $xaxis="mode:\"time\",
            timeformat:\"%y\",
            tickSize:[1,\"year\"],
            tickLength:0,$ticks
            axisLabel: 'Year'";
            $barWidth="1000*60*60*24*180";#1/2 yr (in milliseconds).
    }elseif($type=="day"){#
        $xaxis="mode:\"time\",
            timeformat:\"%m/%d\",
            tickSize:[1,\"day\"],
            tickLength:0,$ticks
            axisLabel: 'Day'";
            $barWidth="1000*60*60*12";#1/2 day (in milliseconds).
    }elseif($type=="halfday"){#
        $xaxis="mode:\"time\",
            timeformat:\"%m/%d\",
            tickSize:[24,\"hour\"],
            tickLength:0,$ticks
            axisLabel: 'Day'";
            $barWidth="1000*60*60*6";#1/4 day (in milliseconds).
    }elseif($type=="weekday_hour"){#super customized not sure how usefull..
        $xaxis="mode:\"time\",
            timeformat:\"%m/%e\",
            tickSize:[24,\"hour\"],
            $ticks
            axisLabel: 'Day'";#Default monthly
            $barWidth="1000*60*60*2";#2 hour (in milliseconds).
            $seriesColor="color: 3,";
    }else{
        $xaxis="mode: null,
                axisLabel: '$type',
                tickSize:1,$ticks
                tickLength:0";
        $timePlot=false;
        $barWidth=".6";
    }

    if($a){

        $options="  series: {
                        $seriesColor
                        stack: true,
                        lines: { show: false, fill:true,steps:false},
                        points: { show: false },
                        bars:{show:true, barWidth: $barWidth,fill: true,lineWidth: 1}
                    },
                    xaxis:{
                        $xaxis
                    },
                    grid:{hoverable:true}";

        #make a custom hover handler to unpack the stacked values.
        $html="<div style='width:$width;height:$height'>
                <script language='JavaScript'>
                    var ${id}_previousPoint = null;
                    function ${id}_toolTip(event,pos,item){
                    $(\"#${id}_displayDiv\").html(\"$description\");//Clear out or set passed display message
                        //console.log(pos);
                        if (item) {
                            if (${id}_previousPoint != item.datapoint) {
                                ${id}_previousPoint = item.datapoint;

                                var x = item.datapoint[0],
                                    y = item.datapoint[1]; for ( var i = 2; i < item.datapoint.length; ++i ) y -= item.datapoint[i];
                                    y=formatNumber(y);
                                $(\"#${id}_displayDiv\").html(y + \" - \" + item.series.label);
                                //showTooltip(item.pageX, item.pageY, y + \" - \" + item.series.label);
                            }
                        }
                    }

                </script>
        ";
    #printGraph($a,$divID="",$plotVar="",$clickFunction="",$hoverFunction="",$seriesOptions=array(),$options="",$autoAssignSeriesToNewYAxis=false,$selectToZoomX=false,$description='',$timePlot=true,$togglePlot=true,$markings='',$yopts='',$showLines=true,$showPoints=true,$xAutoScaleMargin=false,$pointSize=1,$fillPoints=false,$adjustableYAxis=false,$plotColors='',$legendDiv='',$showControlButtons=true){
        $html.=printGraph($a,$id,"","","${id}_toolTip",array(),$options,false,false,$description,$timePlot,true,'','',true,true,false,1,false,false,'',$legendDiv,$showControlButtons)."</div><br><br>";#Some issue with height and text display div spilling over.. put these in for now, can fix later.
    }
    return $html."<script>$(\"#${id}_displayDiv\").html(\"$description\");</script>";
}

function printScrollTable($a,$width,$height,$onClick="",$leftHiddenCols=0){
    #almost working.. pure hackerery


    /*Prints results set from doquery. If you echo below getHTMLHeaderIncludes in the
     *html head section, it will look a little prettier.
     *If $onClick js function name is passed, you must also select a column called 'onClickParam'
     *that contains javascript params to pass to the click method
     *ie,
     *If you have a js:
     *  function editRow(rowNum){...}
     *you would include in the query as first col:
     *  bldsql_col("table.num as onClickParam");
     *and then when calling this:
     *  printTable($a,"editRow",1)
     *which would hide the first col and set this as the row's click event:
     *  onClick='javascript:editRow(".$onClickParams{$i}.")' or similar.
     *You can do multi params too, like
     * ?Not sure of this example, (conceptually works, but don't think the text is correct)... bldsql_col(+",'"+table.name as onClickParam);
     *which will pass something like
     *  editRow(3,5)
     *Note, onClickParam is just passed straight through, so you need to include any needed quotes and commas.
     *Use single quotes like this awkward passed string:
     *  bldsql_col("concat(4,\",'\",'fred',\"'\")")
     *which results in
     *  4,'fred'
     *
     *If width/height passed, this will put into a scrolling div.  Must pass with units (250px or 100%)
     *
     *  $leftHiddenCols is number of leading columns to hide.
     *  $class is optional styling class to use.  Defaults to dbutils (fairly basic) if blank.  Can pass jquery if jquery-ui is already linked.

     *You can also optionally include col 'rowClass' in the output.  If present and set, that class will be applied to the row.
     **/
    $rowStyle="";$mouseOver="";
    $html="";
    $twidth=$width-10;
    $class="dbutils";
    $tableClass="class='$class '";
    if($onClick){
        $rowStyle="style='cursor: pointer;'";
    }
    #$scrollCSS=($tableHeight && false)?"style='height:$tableHeight; overflow:auto;'":"";
    if($a){
        $uniqueID=uniqid("dbutils_printTable");


        #header table
        $html.="<div style='width:$width px;height:$height px;'>
                    <table $tableClass id='${uniqueID}_head'><thead><tr>";
        $row=$a[0];
        $j=1;$sortCounter=0;
        foreach($row as $key=>$val){
            if($j>$leftHiddenCols){#Skip any that should be hidden.
                #$html.="<th><a href='#' onclick=\"ts_resortTable(document.getElementById('${uniqueID}_body',$sortCounter);return false;\">$key<span class='sortarrow'></span></a></th>";
                $html.="<th>$key</th>";
                $sortCounter++;
            }
            $j++;
        }
        $html.="</tr></thead><tbody></tbody></table>";

        #body table
        $html.="<div style='height:100%;overflow:auto;border:thin silver solid;width:100%;'>
                    <table id='${uniqueID}_body' $tableClass><thead></thead><tbody>";

        foreach($a as $row){

            #see if a rowclass was specified.
            $rowClass="";
            if(isset($row['rowClass']))$rowClass=$row['rowClass'];
            $rowClass=($rowClass)?"class='$rowClass'":"";

            #If an onClick was passed, include it in the TR
            if($onClick){
                if (isset($row['onClickParam'])){
                    $html.="<tr $rowStyle $rowClass onClick=\"JavaScript:$onClick(".$row['onClickParam'].");\" >";
                }else{var_dump("Error; missing onClickParam column in query");exit();}#Just for developer reminder.
            }else $html.="<tr $rowClass>";
            $j=1;
            foreach($row as $key=>$val){
                if($j>$leftHiddenCols){#Skip any that should be hidden.
                    $html.="<td>$val</td>";
                }
                $j++;
            }
            $html.="</tr>";

        }
        $html.="</tbody></table></div></div>";

        #Set the header widths to match the body
        $jsH="\"#${uniqueID}_head";$jsB="\"#${uniqueID}_body";#convience
        $html.="<script language='JavaScrip'>
            //$($jsH\").width($($jsB\").width());//Match widths.Shouldn't be needed, but doesn't hurt.
            $($jsH tr th\").each(function (i){
                var hw=$(this).width();
                var bw=$($($jsB tr:first td\")[i]).width();
                var nw=(hw>bw)?hw:bw;
                console.log('h:'+hw+' b:'+bw+' nw:'+nw);
                $(this).width(nw);
                //$($jsB\").find(\"tr td:nth-child(\"+i+1+\")\").width(nw);
                $($($jsB tr td\")[i]).width(nw);
                //$(this).width($($($jsB tr:first td\")[i]).width());
            });
            var hw=$($jsH\").width();
            var bw=$($jsB\").width();
            var nw=(hw>bw)?hw:bw;
            $($jsH\").width(nw);
            $($jsB\").width(nw);
        ";
        #Add row selection highlighting if needed.
        if($onClick)$html.="
                $( $jsB tbody\" ).on( \"click\", \"tr\", function(event) {
                    $(\"#${uniqueID} tr.dbutils_selectedRow\").removeClass(\"dbutils_selectedRow\");//Unselect any previous selection.
                    $(this).addClass(\"dbutils_selectedRow\");//Select current row
                });";
        $html.="</script>";
    }else $html= "No results";
    return $html;
    return "<xmp>$html</xmp>";
}


function sp_getSinglePlot($a,$label,$width,$height,$id="",$position=-1,$plotVar="",$description='',$displayWidth=100,$onClickJSFunction=""){
    /*   ---SEE getSinglePlots Below for wrapper---
     *$a is standard result set with atleast x (datetime) and y (value). Sorted by datetime
     *$label is displayed in plot
     *$width & $height are in pixels.
     *$id is blank to auto generate, pass it if you need to reference plot
     *$position (default -1) is for stacking several plots.  pass in order (start with 1) and -1 for the last one.  This puts x axis at top and bottom and changes colors.
     *$description is plot description when no hover.

     *$displayWidth is width of hover display
     *$onClickJSFunction is called when datapoint clicked and num (data_num) column included in dataset

        style='display: inline;border:thin outset grey;width:50%;min-width:50%;text-align:center;padding-left:5px;padding-right:5px;'
     */

    $html="";
    #if($a){
        $divID='';#TEMP
        $html="";
        $id=($id)?$id:uniqid("flot_");
        $plotVar=($plotVar)?$plotVar:$id."_plotvar";
        $showX=($position>1)?"show:false":"show:true";#Hide xaxis for all in the middle
        $posX=($position=="1")?"position:top,":"";#Show on top for 1st, bottom for last.
        $showX='show:true';$posX='';#playing with this still..
        $seriesColor=($position<0)?0:$position;#colors start at 0, adjust the 'last' row to range.
        $width=$width-$displayWidth;
        $clickable=($onClickJSFunction)?"true":"false";#Sets default for grid/plot although some series (like highlights) might override and turn off.
        #
        $html="     <table style='border-collapse: collapse;padding:0px;margin:0px;'>
                        <tr>
                            <td><div id='${id}_div' class='sp_plot' style='width:${width}px;height:${height}px;min-height:50px;min-width:50px;margin:0;padding:0;border:1px solid black;'></div></td>
                            <td><div id='${id}_displayDiv' style='width:${displayWidth}px;height:${height}px;'></div></td>
                        </tr>
                    </table>
                    <script language='JavaScript'>
                        var ${id}_options={
                            xaxis:{mode:\"time\",timeformat: \"%m/%y\",$posX $showX},
                            yaxis:{show:true,labelWidth:30},
                            grid:{
                                clickable:$clickable,
                                hoverable:true,
                                margin:0,
                                borderWidth:0
                            },
                            series: {
                                lines: { show: true,lineWidth:.5 },
                                points: { show: true, fill: true,fillColor:0 },
                                color: $seriesColor
                            },
                            selection:{mode:'x'},
                        };
                        var ${id}_series=".sp_getSinglePlotSeriesJSON($a,$label).";


                        var $plotVar=$.plot((\"#${id}_div\"),${id}_series,${id}_options);
                        sp_plotVars.push($plotVar);//Add to the array of plots
                        sp_plotIDs.push('${id}');//To build options and divs ids

                        //Bind the hover function
                        $(\"#${id}_div\").bind(\"plothover\",function(event,pos,item){
                            $('#${id}_displayDiv').html(\"$description\");//Clear out or set to passed msg
                            if(item){
                                var time=new Date(item.datapoint[0]);
                                var o=$.datepicker.formatDate('yy-m-d',time);
                                o=\"<div style='border:1px silver solid;'><span>\"+o+\"</span><br><span style='font-weight:600;'> \"+item.datapoint[1]+\"</span></div>\";
                                $('#${id}_displayDiv').html(o);
                            }
                        });
        ";
        #Bind click function if passed.  This assumes that num col (data_num) was selected in datasets.
        #We'll bind a function to this plot to extract the num and pass off to handler.
        #Assumes data series has 3rd element data_num (see sp_getSinglePlotSeriesJSON)
        if($onClickJSFunction )$html.="$(\"#${id}_div\").bind(\"plotclick\",function (event,pos,item){
            if(item){
                ${onClickJSFunction}(item.series.data[item.dataIndex][2]);
            }
        });";

        $html.="    </script>";


        return $html;


}

function sp_getHighLightData($a,$hlnum=1){
    /*Returns an array of date,value arrays from passed result set object that has a x and hl (highlight).
     *Intended to be used with standard result sets when you select x,y & optional hl (1 or 0).
     *Output may not be same size as input.
     *$hlnum can be passed to look for different highlight values.  Caller is responsible.
     **/
    $b=array();
    if($a){
        if(isset($a[0]['x']) && isset($a[0]['hl']) && isset($a[0]['y'])){#Do we have the necessary data?
            #Read data in and create a 'result set' from file to pass back.
            foreach($a as $row){
                if($row['hl']==$hlnum){
                    $date=$row['x'];$value=$row['y'];
                    $b[]=array('x'=>$date,'y'=>$value);
                }
            }
        }
    }
    return $b;
}
function sp_getCurveFitData($a,$sparse=false){
    /*Returns an array of date, smoothed value arrays from passed result set object that has a dd and y (value).
     *Intended to be used with standard result sets when you select dd,value as y
     *Output may not be same size as input.
     **/
    $b=array();

    if($a){
        $cmd="/ccg/bin/ccgcrv";
        if(isset($a[0]['dd']) && isset($a[0]['y']) && is_file($cmd) && is_executable($cmd)){#Do we have the necessary data?
            #Write out date and values to a tmp file
            $tmp=tempnam("/tmp","SP_");
            $fh=fopen($tmp,"w");
            foreach($a as $row){
                fwrite($fh,$row['dd'].' '.$row['y']."\n");
            }
            fclose($fh);
            $res=array();
            #Make call and get results into an array.
            if($sparse)exec($cmd."  -cal -smooth -equal -interv 150 -short 30 -long 200 -npoly 3 -nharm 4 $tmp",$res);
            else exec($cmd."  -cal -smooth -equal -interv 30 -short 80 -long 667 -npoly 2 -nharm 4 $tmp",$res);
            unlink($tmp);

            if($res){
                #Read data in and create a 'result set' from file to pass back.
                foreach($res as $row){
                    $parts = preg_split('/\s+/', $row);
                    $date=$parts[0].'-'.$parts[1].'-'.$parts[2];#build a date
                    $value=$parts[3]+0;#+0 to convert from scientific notation.
                    #$t.="date:$date val:$value<br>";
                    $b[]=array('x'=>$date,'y'=>$value);
                }
            }
        }
    }
    return $b;
}
function plt_getCurveFitData2($a,$interval,$short,$long,$npoly=''){
    /*Returns $a with new col smooth_val  from passed result set object that has a dd and y (value) cols, ordered by dd.
     *Intended to be used with standard result sets when you select dd,value as y
     Pass interval, short, long, npoly blank '' for defaults.  see ccgcrv docs for what those are.
     npoly has a blank default because it was added later.
     **/
    if($a){
        #$cmd="/ccg/bin/ccgcrv";
        $cmd='lib/ccgcrv/ccgcrv.py';#using standalone version so can use on om.
        if(isset($a[0]['dd']) && isset($a[0]['y']) && is_file($cmd) && is_executable($cmd)){#Do we have the necessary data?
            #Write out date and values to a tmp file
            $tmp=tempnam("/tmp","SP_");
            $fh=fopen($tmp,"w");
            foreach($a as $row){
                fwrite($fh,$row['dd'].' '.$row['y']."\n");
            }
            fclose($fh);
            $res=array();
            $i=($interval)?"--interv $interval":'';
            $s=($short)?"--short $short":'';
            $l=($long)?"--long $long":'';
            $np=($npoly)?"--npoly $npoly":'';
            #Make call and get results into an array.NOTE caller icp_funcs_data.php->icp_getCurvedFit() depends on not using -equal option.. it needs same size output
            #var_dump($cmd."  --smooth $i $s $l $np --nharm 4 $tmp");
            exec($cmd."  --smooth $i $s $l $np --nharm 4 $tmp",$res);
            #exec($cmd."  -smooth -interv $interval -short $short -long $long -npoly 3 -nharm 4 $tmp",$res);

            unlink($tmp);
            #var_dump(count($res));var_dump(count($a));

            #For some reason, above exec is stripping space delim when num is negative.  not sure why.  didn't do it
            #on non py version.  detect if so and handle.
            if($res){
                #Read data in and create a 'result set' from file to pass back.
                foreach($res as $i=>$row){
                    $parts = preg_split('/\s+/', $row);
                    if(count($parts)==1){
                        $parts = explode("-", $row,2);
                        if(count($parts)==2)$parts[1]="-".$parts[1];
                        #else var_dump?
                    }
                    $value=(float)$parts[1];#convert from scientific notation.
                    $a[$i]['smooth_val']=$value;
                }
            }else $a=false;
        }
    }
    return $a;
}
function sp_getSinglePlotSeriesJSON($a,$label,$overlayData=false){
    /*Returns value for a series json data obj to use in sp_getSinglePlot.
    $a is standard doquery return with 2 cols (can be more), x and y.  Assumes x is a datetime.
    See getSinglePlots for more details on extra columns.
    */
    $json="[]";$data="";
    #First set up the data array.  Note, this series must come first and if num is passed in resultset, it must be set 3rd (x,y,num) for singleplot caller.
    if($a){
        foreach($a as $i=>$row){
            $y=$row['y'];$x=strtotime($row['x'])*1000;#convert to time format flot is expecting (milliseconds since 1/1/70, (js timestamp)).  Should be?:strtotime($x." UTC")*1000;  UTC was causing issues because dateformat
            $num=(isset($row['num']))?",".$row['num']:'';
            $data.="[$x,$y${num}],";#Add in num (when present) as 3rd element in data array.  This allows click handler to pull it out again.
        }
        $opts=" lines: { show: false,lineWidth:.5 },
                points: { show: true,radius:2},";
        $data=substr($data,0,-1);#Strip trailing comma
    }
    $json="{label:'$label',data:[$data],$opts}";

    #Now we can add other optional series.
    #Note the rest of the series must have clickable turned off as we only add the datanum to the primary data series and we don't want them getting the click event.

    #Get overlay if passed
    if($overlayData){
        $data='';
        foreach($overlayData as $i=>$row){
            $y=$row['y'];$x=strtotime($row['x'])*1000;#convert to time format flot is expecting (milliseconds since 1/1/70, (js timestamp)).  Should be?:strtotime($x." UTC")*1000;  UTC was causing issues because dateformat
            $data.="[$x,$y],";#Add in num (when present) as 3rd element in data array.  This allows click handler to pull it out again.
        }
        $data=substr($data,0,-1);#Strip trailing comma
        $opts=" lines: { show: false,lineWidth:.5 },
                clickable: false,
                points: { show: true,radius:.5},
                color:'#000000'";##8A8A8A
        $json.=",{label:'$label(2)',data:[$data],$opts}";
    }
    #var_dump($json);exit();
    #Get smoothed curve if requested.
    $b=sp_getCurveFitData($a);
    if($b){
        $data="";
        foreach($b as $row){
            $x=strtotime($row['x'])*1000;$y=$row['y'];
            $data.="[$x,$y],";
        }
        $data=substr($data,0,-1);
        $opts=" lines: { show: true,lineWidth:.5 },
                clickable: false,
                points: { show: false},
                color:'#000000'";##8A8A8A
        $json.=",{data:[$data],$opts}";
    }

    #Get any highlights. These are done as a separate plot
    $b=sp_getHighLightData($a);
    if($b){
        $data="";
        foreach($b as $row){
            $x=strtotime($row['x'])*1000;$y=$row['y'];
            $data.="[$x,$y],";
        }
        $data=substr($data,0,-1);
        $opts=" lines: { show: false },
                clickable: false,
                points: { show: true, radius:2},
                color:'#000000'";##8A8A8A
        $json.=",{data:[$data],$opts}";
    }
    #And any double size (2) highlights
    $b=sp_getHighLightData($a,2);
    if($b){
        $data="";
        foreach($b as $row){
            $x=strtotime($row['x'])*1000;$y=$row['y'];
            $data.="[$x,$y],";
        }
        $data=substr($data,0,-1);
        $opts=" lines: { show: false },
                clickable: false,
                points: { show: true, radius:3},
                color:'#000000'";##8A8A8A
        $json.=",{data:[$data],$opts}";
    }

    return "[$json]";
}
function sp_getSinglePlotDynLoadJS($a){
    #Turn result set array into js flot objects for dynamic loading into plot areas.  See getSinglePlots for $a documentation.
    $arr="";
    foreach($a as $label=>$data){
        $arr=appendToList($arr,sp_getSinglePlotSeriesJSON($data,$label));
    }

    //Load into js and use to update plots.  Note, assumes order is consistent.
    $js="
    <script language='JavaScript'>
        sp_loadData([$arr]);
    </script>
    ";
    return $js;
}
function sp3_getSinglePlots($data,$destDiv,$description='',$onClickJSFunction='',$overlayData=false){
    //Updated version of below.
    #Creates a set of linked single gas plots.
    #$data is an array of label=>result set where result set is db result set containing atleast x (datetime) and y(value).
    #Each array entry is a different gas/plot
    #ex:
    /*  function demoSPLoad($fromDate,$toDate){
            $a=array();
            $params=array('co2','ch4','co','n2o','sf6');
            foreach($params as $gas){
                bldsql_init();
                bldsql_from("flask_data_view v");
                bldsql_where("v.parameter=?",$gas);
                bldsql_orderby("v.ev_datetime");
                bldsql_col("v.value as y");
                bldsql_col("v.ev_datetime as x");
                bldsql_where("v.ev_datetime>=?",$fromDate);
                bldsql_where("v.ev_datetime<=?",$toDate);
                bldsql_where("v.value!=-999.99");
                bldsql_where("v.site=?","mlo");
                $a[$gas]=doquery();
            }
            return $a;
        }
    Note label names must be unique

    You can include optional columns for special display:
    -To display a smoothed curve along with the data using ccgcrv:
        include the event digital date as 'dd'
        bldsql_col("d.ev_dd as dd")
    -To highlight a set of points:
        -include a column 'hl' with highlighted datapoints =1, others=0
        -if hl=2, then the points are double sized.
    -To handle a click event;
        -include column 'num' with the data_num
        -include $onClickJSFunction (js) in call to this method.  It will receive num as it's parameter.
            Just include name of method, not parens :"rev_dataClickHandler"
            -You can use the div sp3_plotsJSDiv for a div workspace if needed (hidden).
    -Pass overlayData in same format as data (x datetime/yvalue) to add an overlay plot
    */
    $html='No data.';
    if($data){
        #Build up the json array/obj that the js functions are expecting.  see js sp2_createPlots for details.
        $jsData="";$minX=false;$maxX=false;#track min/max x so we can force all plots to same time line (even when don't have same data)
        foreach($data as $label=>$data2){
            $ol_data=($overlayData)?$overlayData[$label]:false;
            $series=sp_getSinglePlotSeriesJSON($data2,$label,$ol_data);#Plot data
            $d="{plotsTitle:\"$description\",onClickMethod:'$onClickJSFunction', series:$series}";#Plot obj data
            $jsData=appendToList($jsData,$d);#Concat all together
            if($data2){#Find running min/max values.
                $tminX=strtotime($data2[0]['x'])*1000;
                $tmaxX=strtotime($data2[sizeof($data2)-1]['x'])*1000;
                $minX=($minX===false || ($minX!==false && $tminX<$minX))?$tminX:$minX;
                $maxX=($maxX===false || ($maxX!==false && $tmaxX>$maxX))?$tmaxX:$maxX;
                #var_dump("x0:".$data2[0]['x']." xm:".$data2[sizeof($data2)-1]['x']." tminx=$tminX tmaxx=$tmaxX minx=$minX maxx=$maxX");
            }
            #Repeat for overlay data(if present0)
            if($ol_data){#Find running min/max values.
                $tminX=strtotime($ol_data[0]['x'])*1000;
                $tmaxX=strtotime($ol_data[sizeof($data2)-1]['x'])*1000;
                $minX=($minX===false || ($minX!==false && $tminX<$minX))?$tminX:$minX;
                $maxX=($maxX===false || ($maxX!==false && $tmaxX>$maxX))?$tmaxX:$maxX;
            }
        }
        $jsData="var sp3_d=[$jsData];";
        $html="<script language='JavaScript'>var sp_allPlotsMinX=$minX; var sp_allPlotsMaxX=$maxX; $jsData sp3_createPlots(sp3_d,'$destDiv');</script><div id='sp3_plotsJSDiv' class='hidden'></div>";
    }
    return $html;
}
function getSinglePlots($data,$switchDoWhat='',$switchParams='',$width=550,$height=150,$description='',$onClickJSFunction=''){
    #NOTE dt/review/review.js has sp2_ implementation that is better (mostly done in js).  Consider merging that in here. j - 7/18
    ##NOTE NOTE; merged above.. still finalizing.
    #Creates a set of linked single gas plots.
    #$data is an array of label=>result set where result set is db result set containing atleast x (datetime) and y(value).
    #Each array entry is a different gas/plot
    #ex:
    /*  function demoSPLoad($fromDate,$toDate){
            $a=array();
            $params=array('co2','ch4','co','n2o','sf6');
            foreach($params as $gas){
                bldsql_init();
                bldsql_from("flask_data_view v");
                bldsql_where("v.parameter=?",$gas);
                bldsql_orderby("v.ev_datetime");
                bldsql_col("v.value as y");
                bldsql_col("v.ev_datetime as x");
                bldsql_where("v.ev_datetime>=?",$fromDate);
                bldsql_where("v.ev_datetime<=?",$toDate);
                bldsql_where("v.value!=-999.99");
                bldsql_where("v.site=?","mlo");
                $a[$gas]=doquery();
            }
            return $a;
        }

    You can include optional columns for special display:
    -To display a smoothed curve along with the data using ccgcrv:
        include the event digital date as 'dd'
        bldsql_col("d.ev_dd as dd")
    -To highlight a set of points:
        -include a column 'hl' with highlighted datapoints =1, others=0
        -if hl=2, then the points are double sized.
    -To handle a click event;
        -include column 'num' with the data_num
        -include $onClickJSFunction (js) in call to this method.  It will receive num as it's parameter.
            Just include name of method, not parens :"rev_dataClickHandler"

    */



    #Each row gets its own plot.
    #width is total width (including small display on right)
    #height is individual height of each single plot.
    #description will display on top if controls are displayed

    #switchDoWhat and switchParams (optional) are what to pass to ajax call to switch.php to dyanmically load full results for a plot.
    #  ex: "rev_dynLoadSinglePlotsData" and "range_num=${range_num}"  where rev_dynLoadSinglePlotsData is a switch.php 'doWhat' option to rerieve data using key range_num

    #  sp_minDate (small data date), sp_maxDate (largest data date) are passed as additional parameters to switch.php
    #  note, these dates are unix stamps in ms (js timestamps).

    #Ex dyn method:
    /*
        function rev_dynLoadSinglePlotsData($range_num){
            #Returns json array of full data set for js to dynamically load
            $sp_minDate=getHTTPVar("sp_minDate",0,VAL_FLOAT);#unix timestamps in ms, so bigger than an int.
            $sp_maxDate=getHTTPVar("sp_maxDate",0,VAL_FLOAT);

            #Convert back into dates mysql will recognize
            $from=date(DATE_ISO8601,$sp_minDate/1000);#/1000 because this is currently in milliseconds.
            $to=date(DATE_ISO8601,$sp_maxDate/1000);

            $a=rev_getSinglePlotsData($range_num,$from,$to);#Raw data
            return sp_getSinglePlotDynLoadJS($a);#JS to json package and then call function to load.
        }


    */

    $minDate='';$maxDate='';$html="";$displayWidth=100;$controlWidth=$width-$displayWidth;

    $plots="<table>";
    $i=0;$numPlots=sizeof($data);
    foreach($data as $label=>$plotData){
        if($plotData){
            if(!$minDate)$minDate=$plotData[0]['x'];#just need to grab once, should all be the same.
            if(!$maxDate)$maxDate=$plotData[sizeof($plotData)-1]['x'];
        }
        $i=($i==sizeof($data)-1)?-1:$i+1;#Increment counter and set last 1 -1 for colors and x axis display.
        $plots.="<tr><td>".sp_getSinglePlot($plotData,$label,$width,$height,'',$i,'','',$displayWidth,$onClickJSFunction)."</td></tr>";
    }
    $plots.="</table>";

    $html.="<script language='JavaScript'>
                sp_plotVars=[];//Global array to hold pointers to various plots.  Set in page, reset every load.
                sp_plotIDs=[];//Ditto for unique ids.

                var sp_minDate=new Date('$minDate').getTime();
                var sp_maxDate=new Date('$maxDate').getTime();
                var sp_origMinDate=sp_minDate;var sp_origMaxDate=sp_maxDate;
                var sp_shiftLength=sp_maxDate-sp_minDate;//Slider increments
                var sp_plotHeight=$height;var sp_plotWidth=$controlWidth;
                var sp_hwRatio=sp_plotHeight/sp_plotWidth;

                $(window).resize(function(){sp_resizeContainer(0,0)});
                sp_resizeContainer();
                function sp_resizeContainer(){
                    //Set the container div height based on whatever div we're put into.  We'll just reset every time to be sure.
                    var parentHeight=$('#sp_containerDiv').parent().innerHeight();
                    var parentWidth=$('#sp_containerDiv').parent().innerWidth();
                    var controllerHeight=$('#sp_controllerDiv').height();
                    var displayWidth=$displayWidth;//Side on hover divs
                    var newPlotWidth=(parentWidth-displayWidth)-30;
                    //console.log('ph'+parentHeight+' pw'+parentWidth+'ch'+controllerHeight+' npw'+newPlotWidth);
                    $('#sp_containerDiv').height(parentHeight-10);//Set to be the same as parent.
                    $('#sp_containerDiv').width(parentWidth);//Set to be the same as parent.
                    $('#sp_scrollingPlotsDiv').height(parentHeight-controllerHeight);
                    $('#sp_scrollingPlotsDiv').width(parentWidth);

                    sp_plotHeight=sp_plotHeight+((newPlotWidth-sp_plotWidth)*sp_hwRatio);//Increase height by same ratio as width
                    sp_plotWidth=newPlotWidth;

                }
                //hmm. this one not used.  I think it was a hold over, but we still need to program something similar.
                function sp_resizePlots(vert,horz){
                    //Adjust all the plots to new size.  May not be any there yet.
                    sp_plotHeight+=vert;sp_plotWidth+=horz;
                    //loop through each of the plots and resize
                    for(i=0;i<sp_plotIDs.length;i++){
                        var id=sp_plotIDs[i];
                        var plot=sp_plotVars[i];
                        $('#'+id+'_div').width(sp_plotWidth);
                        $('#'+id+'_div').height(sp_plotHeight);
                        plot.setupGrid();
                        plot.draw();
                    }
                    sp_setDisplay();
                    //Controller area too.
                    $('.sp_controlTable').width(sp_plotWidth);

                }
            </script>";


    #If dynamic loading is enabled, set up the control structures and js code.
    if($switchParams){
        #Set up the slider controls html.. we do it here so can be replicated on bottom of plots.  Note, we use class identifiers instead of ids so that we can apply to top and bottom (when there).
        if($description)$description="<span style='border:1px silver solid;' class='title4'>&nbsp;$description&nbsp;</span>";
        $sliders="  <div style='height:30px;width:${controlWidth}px;border:thin silver outset' id='sp_controllerDiv'>
                    <table class='sp_controlTable' width='100%' style='border-collapse: collapse;padding:0px;margin:0px;'>
                        <tr>
                            <td align='left'>
                                <input class='sp_controlButtons sp_slideLeft' type='button' value='&lsaquo;'>
                                <span class='sp_minDate'></span>
                            </td>
                            <td align='center'>$description
                                <span style='float:right'>
                                    <input class='sp_reset sp_controlButtons' type='button' value='Reset'>
                                    <input class='sp_controlButtons sp_unzoom' type='button' value='Un-Zoom'>
                                </span>
                            </td>
                            <td align='right'>
                                <span class='sp_maxDate'></span>
                                <input  class='sp_controlButtons sp_slideRight' type='button' value='&rsaquo;'>
                            </td>
                        </tr>
                    </table>
                    </div>
                ";
        $slidersBottom=($numPlots>2 && false)?$sliders:"";#Only include on the bottom if theres
        $html.="
                <div style='width:100%;height:100%' id='sp_containerDiv'>
                    $sliders
                    <div id='sp_scrollingPlotsDiv' class='scrolling' style='width:100%;height:100%;'>$plots</div>
                    <div id='sp_jsdiv'></div>
                </div>

            <script language='JavaScript'>
                $('.sp_controlButtons').button();//jqueryify buttons

                $('.sp_unzoom').hide();//We'll only show this when zoomed (below).
                $('.sp_reset').hide();//ditto for reset.

                $('.sp_slideLeft').click(function(){
                    sp_slidePlots(-1);
                });
                $('.sp_slideRight').click(function(){
                    sp_slidePlots(1);
                });
                $('.sp_unzoom').click(function(){
                   sp_unzoom();
                });
                $('.sp_reset').click(function(){
                   sp_resetData();
                });
                $('.sp_resize').click(function(){
                   sp_resize(5,0);
                });

                sp_setDisplay();

                function sp_slidePlots(num){
                    //Slide plots left or right by # of sp_shiftLength.  Pass +- 1 like -1 to move left 1 block and 1 to move right

                    //Adjust the min/max
                    sp_minDate+=num*sp_shiftLength;
                    sp_maxDate+=num*sp_shiftLength;
                    sp_fetchData();
                }

                function sp_fetchData(){
                    //Disable buttons so they don't send multiple requests
                    $('.sp_controlButtons').button('disable');

                    //Send request for more data
                    ajax_get('$switchDoWhat','$switchParams&sp_minDate='+sp_minDate+'&sp_maxDate='+sp_maxDate,'sp_jsdiv');

                    //Set display text
                    $('.sp_minDate').html('Loading more data...');
                    $('.sp_maxDate').html('');

                }
                function sp_loadData(sp_all_data){
                    //load passed dataset
                    for(i=0;i<sp_all_data.length;i++){
                        var id=sp_plotIDs[i];
                        var series=sp_all_data[i];
                        var options=window[id+'_options'];//Window is supposed to have access to all globals (hopefully cross browser).
                        var plot=sp_plotVars[i];
                        plot.setData(series);
                        plot.getOptions().xaxes[0].min=sp_minDate;
                        plot.getOptions().xaxes[0].max=sp_maxDate;
                        plot.setupGrid();
                        plot.draw();
                    }
                    sp_setDisplay();
                }
                function sp_resetData(){
                    //Sets back to original state
                    sp_minDate=sp_origMinDate;
                    sp_maxDate=sp_origMaxDate;
                    for(i=0;i<sp_plotIDs.length;i++){
                        var id=sp_plotIDs[i];
                        var series=window[id+'_series'];
                        var options=window[id+'_options'];
                        var plot=sp_plotVars[i];
                        plot.setData(series);
                        plot.getOptions().xaxes[0].min=sp_minDate;
                        plot.getOptions().xaxes[0].max=sp_maxDate;
                        plot.setupGrid();
                        plot.draw();
                    }
                    sp_setDisplay();
                }

                function sp_setDisplay(){
                    $('.sp_controlButtons').button('enable');//[re]enable all buttons.

                    if(sp_minDate!=sp_origMinDate){//Enable reset button
                        $('.sp_reset').show();
                    }else{
                        $('.sp_reset').hide();
                    }
                    $('.sp_unzoom').hide();

                    $('.sp_minDate').html(ymdDate(new Date(sp_minDate)));
                    $('.sp_maxDate').html(ymdDate(new Date(sp_maxDate)));
                }
                function sp_setDateRange(min,max){

                }
                //Set up selection handlers.

                $(\".sp_plot\").bind(\"plotselected\", function (event, ranges) {//Allows user to select a section of displayed plot to zoom in on.
                    for(i=0;i<sp_plotIDs.length;i++){
                        var id=sp_plotIDs[i];
                        var plot=sp_plotVars[i];
                        $.each(plot.getXAxes(), function(_, axis) {
                            var opts = axis.options;
                            opts.min = ranges.xaxis.from;
                            opts.max = ranges.xaxis.to;
                        });
                        plot.setupGrid();
                        plot.draw();
                        plot.clearSelection();
                    }
                    $('.sp_unzoom').show();//Show button to un-zoom
                });
                function sp_unzoom(){//Resets zoom window to all available data.
                    for(i=0;i<sp_plotIDs.length;i++){
                        var id=sp_plotIDs[i];
                        var plot=sp_plotVars[i];
                        $.each(plot.getXAxes(), function(_, axis) {
                            var opts = axis.options;
                            opts.min = sp_minDate;
                            opts.max = sp_maxDate;
                        });
                        plot.setupGrid();
                        plot.draw();
                        plot.clearSelection();
                    }
                    $('.sp_unzoom').hide();
                }
                //sp_plotVars.forEach(function(plot){
                //    plot.getOptions().xaxes[0].min=(new Date('2015-07-01')).getTime();
                //    plot.getOptions().xaxes[0].max=(new Date('2015-07-31')).getTime();
                //});

            </script>";
    }else $html.=$plots;//#just the plots.

    return $html;

}

##################

#function printGraph_preAdjYAxis($a,$divID="",$plotVar="",$clickFunction="",$hoverFunction="",$seriesOptions=array(),$options="",$autoAssignSeriesToNewYAxis=false,$selectToZoomX=false,$description='',$timePlot=true,$togglePlot=true,$markings='',$yopts='',$showLines=true,$showPoints=true,$xAutoScaleMargin=false,$pointSize=1,$fillPoints=false,$adjustableYAxis=false){
    /*Returns html/js to print a graph of resultset $a.  Must call get_dbutilsHeaderIncludes or manually include jquery.flot.js
     *Also requires some version of jquery to be already linked.
     *
     *$a is standard result set from doquery with 3 required columns:
     *series (label string ex 'co2'), x (datetime), y (float)
     *and optional columns:
     *  end_point: (1/0) that if specified will stop a line in the series (for a gap).  Next result will start back up.
     *  series_color: can either be a number from 0 to number of series to specify a specific auto generated color
     *      or a rgb(n,n,n) color
     *  yaxis:(int default 0).  This value is for the whole series.  (only the first one in the series is actually read)
     *      if zero, all series are added to the same yaxis
     *      if>0, series is assigned to that yaxis
     *      if<0 series is automatically assigned a new yaxis
     *  highlightPoint:(int 0 (default) or 1) pass a value of 1 to highlight the point
     *  unc: if passed, then error bars are drawn
     *
     *result set must be ordered by series, x
     *
     *Ex select: select 'co2' as 'series', timestamp(date,time) as x, value as y from flask_data where parameter=1 and site_num=75 order by date,time
     *
     *Calling with just $a uses fairly good defaults, but you can customize with options:
     *
     *$divID: pass to specifiy what to call div.  Note! there is a bug below if the divID starts with a number (i think),
     *so if you pass a divID, prefix with chars like this:
     *$divID=uniqid("flotgraph_");
     *
     *$plotVar: pass a name to use for the plot variable if you want to be able to reference later (like to refresh or reload data).  If
     *blank, a random one is assigned.
     *
     *$clickFunction: pass a js function name to use as a call back when graph is clicked.  It will get parameters event,pos,item
     *$hoverFunction: same or pass 'default' to have '(series name) value' put into a message box below the graph.  If you include
     * a hoverLabel column, that text will get used.
     *
     *options paramters can customize the output.  See see flot doc for details (https://github.com/flot/flot/blob/master/API.md)

     *$seriesOptions is an array of  non default options for each flot series.  The series name is the key
     *and the value is a json string of options for that series.  Options must be in json format as flot expects.
     *We just append whatever is passed into the series object, so any valid options inside of a series object can go in here.
     *syntax is like:
     *$seriesOptions["co2"]= "lines: { show: true }, points: { show: true },yaxis:2";
     *
     *Not all series need a line.
     *
     *$options: can be any valid options to pass in flot's 3rd param (options param).
     *Can be defaults for all series or grid, whatever flot accepts.  Must be in json format.
     *We basically just wrap in {} and assign
     *passed options to a js variable and pass to flot.
     *ex: "series: { lines: { show: true }, points: { show: true }}"
     *to set default show=true for all series and points
     *
     *Note!  if options is passed, it overwrites the clickable:true and hoverable:true that get set when clickFunction or hoverFunction is
     *passed.  So if you pass options and want a click/hover function, you must set clickable:true and hoverable:true as appropriate in the
     *option array:
     *"series: { lines: { show: true }, points: { show: true }},xaxis:{mode:\"time\",timeformat:\"%Y/%m/%d\"}, grid:{clickable:true,hoverable:true}"
     *The passed function names are still bound to callbacks though.

     *Note by default xaxis is defined to be time based.  This can be overridden with custom options array though.
     *Set $timePlot=false if not using a time based x axis.
     *
     *$autoAssignSeriesToNewYAxis:if true, each series gets assigned to a new yaxis.  You can also specify this in the select by
     *including a yaxis col (-1 auto, 0 all to 1 yaxis, >0 assigned to specific access).
     *Default false assigns all to the same axis.
     *
     *$selectToZoomX: pass true to allow user to select a band on x axis to zoom.  Also adds a reset button.  If false, default is scroll wheel zoom and pan support.  Default may be better (its a pluggin I found)
     *
     *$description: if passed, will be displayed under plot (except when hover event uses it).
     *Note! don't pass double quotes (if you need to, you'll need to edit function below to escape them.)Don't pass user input
     *
     *$timePlot: (default true) true if a time based plot (below logic sets up date labels)
     *
     *$togglePlot: (default true) if more than one yaxis and true, then clicking the axis label toggles the plot on and off.
     *NOT TESTED yet.. should be close, but project I was adding to used custom options, so couldn't test easily.. I think
     *just the labels links need to be debugged.  (seems to work in dt review aircraft thing I was adding too..)
     *
     *$markings, if passed will draw lines on plot. (unless you override options, then you need to set.)
     *  in form like {yaxis: {from:5, to: 6}, color:\"rgb(16,177,10)\",lineWidth:2},{yaxis: {from:$i, to: $i}, color:\"$cColor\",lineWidth:$w}
     *  See docs for details
     *
     *$yopts, if passed are yaxis specific options like: "min:0,max:24".  This is available so you don't have to roll your own whole options block if you just want to set ticksize or min/max

     *Here's an ex for co2 and ch4 from MLO, pair averaged. Note requires jquery linked and then get_dbutilsHeaderIncludes() to link graphing lib
        bldsql_init();
        bldsql_from("flask_data_view v");
        bldsql_col("v.parameter as 'series'");
        bldsql_col("timestamp(v.ev_date,v.ev_time) as x");
        bldsql_col("avg(v.value) as y");
        bldsql_where("v.parameter_num in (1,2)");
        bldsql_where("v.site='mlo'");
        bldsql_where("v.ev_date>?",'2015-01-01');
        bldsql_groupby("v.parameter");
        bldsql_groupby("timestamp(ev_date,ev_time)");
        $seriesOptions['co2']="yaxis:2";
        $options="yaxes:[{},{position:\"right\"}]";
        echo "<div id='graphDiv' style='width:800px;height:500px;'>".printGraph(doquery())."</div>";

    The auto scaling on xaxis when in time mode doesn't always seem to work.  Pass a value in $xAutoScaleMargin to force a margin (like 0.1)

    $pointSize=1 by default, pass any number for radius size

    $fillPoints is false by default (points dipslayed as circle).  Pass true to have them filled in.
    if $adjustableYAxis, then a slider is added to adjust the y axis.
     */
/*
    $html="";
    $xmargin=($xAutoScaleMargin!==false)?",autoscaleMargin:$xAutoScaleMargin":"";
    if(!$divID)$divID=uniqid("flotgraph_");
    $html=" <div id='${divID}_outer' style='width:100%;height:100%;min-height:50px;min-width:50px;text-align:center'>";
    if($adjustableYAxis)$html.="<table style='width:100%;height:100%;'><tr><td><div id='$divID' style='width:100%;height:100%;'></div></td><tr><td valign='bottom'><div style='height:180px' id='${divID}_yrangeSlider'></td></tr></table>";
    else $html.="<div id='$divID' style='width:100%;height:100%;'></div>";
    if($description || $hoverFunction=='default')$html.=" <div id='${divID}_displayDiv' style='display: inline;border:thin outset grey;width:50%;min-width:50%;text-align:center;padding-left:5px;padding-right:5px;'>&nbsp;</div>";
    if($selectToZoomX){#Add zoom buttons, handlers and reset above div height to fit them.
        $html.="<div id='${divID}_zoomBtns' style='float:right;display:inline'>
                    Zoom <button id='${divID}_zoomOut' style='font-size: smaller;'>-</button>
                    <button id='${divID}_zoomIn' style='font-size: smaller;'>+</button>
                </div><script language='JavaScript'>
                    var buttonH=$(\"#${divID}_zoomBtns\").outerHeight();
                    var outerH=$(\"#${divID}_outer\").outerHeight();
                    $(\"#$divID\").height(outerH-buttonH);
                </script>";
    }
    $html.="</div>";

    $plotVar=($plotVar)?$plotVar:$divID."_plotvar";
    $minX=false;$maxX=false;$setYRange=false;$minY=false;$maxY=false;$hasErrBars=false;
    if($a){
        #Loop through the result set to create each series.
        $seriesKey="firstloop";$dataObj="";$sObj="";$dataSet="";$highlights="";$highlightPoint=0;$hoverLabel="";$hoverLabelArr="";$hoverLabelArrEls="";$unc=false;
        $end_point=0;#note end_point may be overridden in below extract, this is default value if not in select.
        $series_color=0;#ditto
        $yaxis=0;#ditto
        $c=1;$seriesIndex=-1;$dataPointIndex=-1;#Series/DatapointIndex are zero based, so need to start -1 so first one is 0.
        foreach($a as $row){
            extract($row);
            $dataPointIndex++;
            if($seriesKey!=$series){
                $seriesIndex++;$dataPointIndex=0;#Series increments, dataPointIndex starts over for each series, starting at 0
                #New (or first) series, set it up.  If a new one, close off the previous before starting new one.
                $seriesKey=$series;
                #close previous and append to dataObj
                if($sObj)$dataObj=appendToList($dataObj,$sObj,",")."$dataSet]}";#Add comma if 2nd+,sObj,$dataSet, then close $data ], then close series }

                #Start new series
                $sObj='{label:"'.$seriesKey.'",';
                #add options from select
                if($series_color)$sObj.="color:\"$series_color\",";
                if($yaxis>0)$sObj.="yaxis:$yaxis,";
                if($yaxis<0 || $autoAssignSeriesToNewYAxis){
                    #auto assign to a new axis
                    $sObj.="yaxis:$c,";
                    $c++;
                }
                if($unc!==false){
                    #add error bar logic
                    $sObj.=" points:{show:true, errorbars:'y', yerr:{show:true,upperCap:'-',lowerCap:'-'}},lines:{show:false},";
                    $setYRange=true;#Y range auto size doesn't work on the min (sets to zero) for some reason when this option is on.NOt sure if this works with multiple y axises
                    $hasErrBars=true;#so we can know whether to hide below..
                }
                #See if any optional params were passed in call
                if(isset($seriesOptions[$seriesKey])){
                    $sObj.=$seriesOptions[$seriesKey].",";
                }
                #start the data array
                $sObj.='data:[';
                $dataSet="";
                #If tracking hoverlabels, add a new series array.
                if($hoverLabel)$hoverLabelArr.="${divID}_hoverLabelArr[$seriesIndex]=[];";
            }
            #append in the data points
            #first convert datetime to js time value
            if($timePlot)$x=strtotime($x)*1000;#if($timePlot)$x=strtotime($x." UTC")*1000;  UTC was causing issues because dateformat (for label display) changed to local time.  Hopefully setting to local initially will take care of it.
            $minX=($minX===false || ($x<$minX && $x>-999))?$x:$minX;#track the smallest/largest we've seen for zooming logic.
            $maxX=($maxX===false || $x>=$maxX)?$x:$maxX;
            $u=($unc===false)?0:$unc;
            $minY=($minY===false || ($y-$u)<$minY)?($y-$u):$minY;
            $maxY=($maxY===false || ($y+$u)>=$maxY)?($y+$u):$maxY;
            $errBarSize=($unc!==false)?",$unc":"";#Add in unc data if present
            #$dataSet=appendToList($dataSet,"[$x,$y${errBarSize}]",",");
            appendToList2($dataSet,"[$x,$y${errBarSize}]",",");
            if($end_point)$dataSet.=",[null,null]";#Add the terminator flag to stop drawing the line.
            #if($highlightPoint)$highlights=appendToList($highlights,'['.$seriesIndex.','.$dataPointIndex.']',",");
            if($highlightPoint)appendToList2($highlights,'['.$seriesIndex.','.$dataPointIndex.']',",");

            #If tracking hoverlabels, then set in datastructure.. indexed by series/datapoint
            if($hoverLabel)$hoverLabelArr.="${divID}_hoverLabelArr[$seriesIndex][$dataPointIndex]='$hoverLabel';";
        }
        $togglePlot=($togglePlot && ($seriesIndex>1 || $yaxis>0));#Are we allowing toggle logic?

        $dataObj=appendToList($dataObj,$sObj,",")." $dataSet]}";#Add comma if 2nd+,sObj,$dataSet, then close $data ], then close series }
        #We should how have 1+ series, wrap in array and set in var
        $js="var ${divID}_data=[$dataObj];";

        #Build up the options
        $js.="var ${divID}_options={";
        if($options)$js.=$options;#Use whatever was passed
        else{
            #build up a default set
            $t_showLines=($showLines)?"true":"false";
            $t_showPoints=($showPoints)?"true":"false";
            $pointSize=($showPoints && $pointSize!=1)?", radius:$pointSize":"";
            $pointFill=($showPoints && $fillPoints)?",fill:1,fillColor:false":"";
            $js.="lines:{ show: $t_showLines }, points: { show: $t_showPoints $pointSize $pointFill},";

            if($timePlot)$js.="xaxis:{mode:\"time\" $xmargin}";#,timeformat:\"%Y-%m-%d\"
            else $js.="xaxis:{}";
            if($setYRange){
                $ymin=$minY-(($maxY-$minY)*0.05);#5% of total range.
                $ymax=$maxY+(($maxY-$minY)*0.05);
                $yopts=appendToList($yopts,"min:$ymin,max:$ymax",",");#add in a min if needed.
            }
            if($yopts)$js.=",yaxis:{ $yopts }";
            #Event handlers?
            $t="";
            if($clickFunction) $t="clickable:true";
            if($hoverFunction) $t=appendToList($t,"hoverable:true",",");
            #plot lines?
            if($markings){
                $markings="markings:[$markings]";
                $t=appendToList($t,"$markings",",");
            }
            if($t)$js.=",grid:{".$t."}";
            #Add clickable legend links if toggle mode on. NEEDS to be tested and debugged...
            if($togglePlot ) $js.=",legend: {
                                        labelFormatter: function(label, series){
                                          return '<a href=\"#\" onClick=\"togglePlot_${plotVar}(\''+label+'\'); return false;\">'+label+'</a>';
                                        }
                                    }";
            if(!$selectToZoomX)$js.=",zoom: {interactive: true},pan: {interactive: true}";#Do mouse wheel and pan by default
        }
        $SelJS="";

        if($selectToZoomX){#Do all the js voodoo to make the select to zoom and zoom buttons work.
            $js.=",selection:{mode:\"x\"}";
            $SelJS="var ${divID}_lastMinX=$minX;
                    var ${divID}_lastMaxX=$maxX;
                    $(\"#$divID\").bind(\"plotselected\", function (event, ranges) {

                        $.each($plotVar.getXAxes(), function(_, axis) {
                            var opts = axis.options;
                            opts.min = ranges.xaxis.from;
                            opts.max = ranges.xaxis.to;
                            ${divID}_lastMinX=ranges.xaxis.from;//Track for below zoom buttons.
                            ${divID}_lastMaxX=ranges.xaxis.to;
                        });
                        $plotVar.setupGrid();
                        $plotVar.draw();
                        $plotVar.clearSelection();
                        });
                    $(\"#${divID}_zoomOut\").bind(\"click\").click(function () {
                        ${divID}_zoomPlotOut();
                    });
                    $(\"#${divID}_zoomIn\").bind(\"click\").click(function () {
                        ${divID}_zoomPlotIn();
                    });
                    //Wheel support was a little wonky (too fast),so I disabled for now..
                    //$(\"#$divID\").bind('mousewheel DOMMouseScroll', function(event){
                    //    if()
                    //    if (event.originalEvent.wheelDelta > 0 || event.originalEvent.detail < 0) {
                    //        // scroll up
                    //        ${divID}_zoomPlotOut();
                    //    }
                    //    else {
                    //        // scroll down
                    //        ${divID}_zoomPlotIn();
                    //    }
                    //});
                    function ${divID}_zoomPlotOut(){
                        $.each($plotVar.getXAxes(), function(_, axis) {
                            var opts = axis.options;
                            var step = ($maxX-($minX))/10;//10% per click
                            var newMin=${divID}_lastMinX-step;
                            if(newMin<$minX)newMin=$minX;
                            var newMax=${divID}_lastMaxX+step;
                            if(newMax>$maxX)newMax=$maxX;
                            opts.min = newMin;
                            opts.max = newMax;
                            ${divID}_lastMinX=newMin;
                            ${divID}_lastMaxX=newMax;
                        });
                        $plotVar.setupGrid();
                        $plotVar.draw();
                        $plotVar.clearSelection();
                    }
                    function ${divID}_zoomPlotIn(){
                        $.each($plotVar.getXAxes(), function(_, axis) {
                                var opts = axis.options;
                                var step = ($maxX-($minX))/10;
                                var mid = $minX+(($maxX-($minX))/2);
                                var midBand=1000;

                                var newMin=${divID}_lastMinX+step;
                                if(newMin>(mid-midBand))newMin=mid-midBand;
                                var newMax=${divID}_lastMaxX-step;
                                if(newMax<(mid+midBand))newMax=mid+midBand;
                                opts.min = newMin;
                                opts.max = newMax;
                                ${divID}_lastMinX=newMin;
                                ${divID}_lastMaxX=newMax;
                            });
                            $plotVar.setupGrid();
                            $plotVar.draw();
                            $plotVar.clearSelection();
                    }

                    ";
        }
        #close out
        $js.="};";

        $js.="var $plotVar=$.plot((\"#${divID}\"),${divID}_data,${divID}_options);";

        #Add alt hover array if needed/set
        if($hoverLabelArr)$js.="var ${divID}_hoverLabelArr=[];$hoverLabelArr";#create 2 d structure (filled above).

        #bind event handlers if needed.
        if($clickFunction)$js.="$(\"#${divID}\").bind(\"plotclick\",function (event,pos,item){ ${clickFunction}(event,pos,item);});";
        if($hoverFunction=='default'){#Puts a datapoint label in the little box below the plot.
            $js.="$(\"#${divID}\").bind(\"plothover\",function (event,pos,item){
                    $(\"#${divID}_displayDiv\").html(\"$description\");//Clear out or set passed display message
                        if (item) {";
            if($hoverLabelArr){#Labels passed from query, set into hoverLabelArr above.. just output directly.
                $js.="      var o=${divID}_hoverLabelArr[item.seriesIndex][item.dataIndex];";
            }else{#build up a 'date (series label): value' string
                $js.="      var time=new Date(item.datapoint[0]);
                            var o=$.datepicker.formatDate('M d, yy',time);
                            o=\"<span>\"+o+\"</span>&nbsp;&nbsp;(\"+item.series.label+\"):<span style='font-weight: 600;'> \"+item.datapoint[1]+\"</span>\";
                ";
            }
            $js.="
                            $(\"#${divID}_displayDiv\").html(o);
                        }
                    });
                $(\"#${divID}_displayDiv\").html(\"$description\");";
        }
        elseif($hoverFunction)$js.="$(\"#${divID}\").bind(\"plothover\",function (event,pos,item){ ${hoverFunction}(event,pos,item);});";

        #Add highlight logic if needed.
        if($highlights){
                $js.="function ${divID}_highlightPoints(plotVar,arr) {
                    for (var i=0, len=arr.length; i<len;i++){
                        var a=arr[i];
                        //console.log(a);
                        plotVar.highlight(a[0],a[1]);
                    }

                }
                var ${divID}_highlights=[$highlights];
                ${divID}_highlightPoints($plotVar,${divID}_highlights);";

        }

        #Toggle plots?
        if($togglePlot){
            #These should be refactored.. I think this was all experimental and not fully set yet, but adding in errorbar support too.12/17
            $errBarsShow=($hasErrBars)?"someData[seriesIdx].points.yerr['show']=true;":"";
            $errBarsHideI=($hasErrBars)?"someData[i].points.yerr['show']=false;":"";
            $errBarsHide=($hasErrBars)?"someData[seriesIdx].points.yerr['show']=false;":"";
            $errBarsHideShow=($hasErrBars)?"someData[seriesIdx].points.yerr['show']= !someData[seriesIdx].points.yerr['show'];":"";
            $js.="
            var togglePlot_${plotVar} = function(label)
            { //console.log(label);
              var seriesIdx=-1;
              var someData = ${plotVar}.getData();
              for(var i = 0, len=someData.length;i<len;i++){
                //console.log(someData[i]);
                if(someData[i].label==label){seriesIdx=i;}
              }
              someData[seriesIdx].points.show = !someData[seriesIdx].points.show;
              someData[seriesIdx].lines.show=!someData[seriesIdx].lines.show;
              $errBarsHideShow
              ${plotVar}.setData(someData);
              ${plotVar}.draw();
            };";

        }

       sftp://mund:@omi//var/www/html/inc/dbutils/dbutils.php $html.="<script language='JavaScript'>$js $SelJS</script>";
    }else $html.="No data to graph.";

    return $html;
}*/
function streamPDF($filename){
    /*Stream pdf directly to browser*/

    if (file_exists($filename)) {
        // Set the appropriate headers for PDF
        header('Content-Type: application/pdf');
        header('Content-Disposition: inline; filename="' . basename($filename) . '"');
        header('Content-Length: ' . filesize($filename));
        header('Cache-Control: private, max-age=0, must-revalidate');
        header('Pragma: public');

        // Read the file and stream it to the client
        readfile($filename);
    } else {
        // File not found
        http_response_code(404);
        echo 'File not found.';
    }


}
function streamIMG($filename,$width=0,$height=0){
	#stream  file to output buffer as jpg image.  This does not return
	#filename is full path.  set $width or height =0 to auto calculate from other
	#Had strange problems getting resize to
	#do anything, but seems to be working now.
	#In use on sheetscanner (omi) if you need to test after messing with it.

	if($filename){
	    header('Content-Type: image/jpg');
        header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
        header("Expires: 0");
        header("Pragma: public");

        $im = new \Imagick();
        $im->readImage($filename);

	    if(preg_grep('~\.(pdf)$~i', array($filename))){
	    #This is still just printing first page for some reason.
	        $pageCount = $im->getNumberImages();
            for ($pageNumber = 0; $pageNumber < $pageCount; $pageNumber++) {
                $im = new \Imagick();
                $im->setResolution(300,300);
                #$im->setIteratorIndex($pageNumber);
                $im->readImage($filename."[${pageNumber}]");
                if($width || $height)$im->scaleImage($width,$height);
                $im->setImageFormat('jpg');
                $im->setImageCompression(imagick::COMPRESSION_JPEG);
                $im->setImageCompressionQuality(100);
                echo $im->getImageBlob();
            }
            #$im->readImage($filename.'[0]');#pdf, take page zero
	    }else{
	        #$im = new \Imagick();
            $im->setResolution(300,300);
	        $im->setImageCompressionQuality(0);
            if($width || $height)$im->scaleImage($width,$height);
            $im->setImageFormat('jpg');
            $im->setImageCompression(imagick::COMPRESSION_JPEG);
            $im->setImageCompressionQuality(100);
            echo $im->getImageBlob();
        }

    }
    exit();
}
function fullWindowImage($imgURL,$title){
    //returns content for full window image
    #Note, if imgURL is dynamic (php page that streams image),
    #you should add a uniqifier to it to prevent cacheing
    #&uid=".uniqid()."
    $html="<html><head><title>$title</title>
        <style>
            html,body{
                margin:0;
                width:100%;
            }
            img{
              display:block;
              width:100%;
              object-fit: cover;
              border:thin silver solid;
            }
        </style>
        <body><img src='$imgURL' alt='$title'></body></html>
    ";
    return $html;
}
function printMap($a,$onClick='',$height='100%',$width='100%',$divID='',$lat=0.0,$lon=0.0,$zoom=1){
#Print a map with data
#Note, must set $includeMapLib=true in index.php (ahead of require_once(...index_funcs.php))
#$a is a doquery() object containing required: label, lat, lon
#   optional: color, onClickParam
#height/width are full text : '1200px'
#if divID not set, a unique one is created.
#onclick js function when marker is clicked, You must select an onClick param (like site_num) in the $a cols.

    $uniqueID=($divID)?$divID:uniqid("dbutils_printMap");
    $html="<div id='$uniqueID' style='max-width: $width; height: $height; margin: auto;'></div>
            <script>var $uniqueID;lm_makeMap('$uniqueID',$lat,$lon,$zoom);";

    foreach($a as $row){
        $color='#00ff15';$onClickParam='';$f='function(e){console.log("map clicked")}';#wasteful, but I think there will usually be a click function anyway, so I like being able to dynamically create it.
        extract($row);#overwrites any defaults
        if($onClick && $onClickParam)$f="function(e){".$onClick."('".$onClickParam."');}";

        $html.="var marker = lm_createMarker($lat,$lon,'$label','$color',$f);";
    }

    $html.="</script>";
    return $html;
}
?>
