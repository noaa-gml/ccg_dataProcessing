<?php
function getRangeCriteriaEditDetails($range_num){
    $html="";
    if($range_num){
        #Call sp to get tag range info.
        doquery("create temporary table t_range_nums as select num from tag_ranges where num=$range_num",false);
        doquery("call tag_getTagRangeInfo()",false);#Fills t_range_info table.
      
        bldsql_init();
        bldsql_from("t_range_info v");
        bldsql_where("range_num=?",$range_num);
        bldsql_col("prettyStartDate as start");
        bldsql_col("prettyEndDate as end");
        bldsql_col("rowcount");
        bldsql_col("prettyRowCount");
        bldsql_col("display_name");
        $a=doquery();
        if($a){
            extract($a[0]);
            $html="
            <div align='center'><br><br><br>
                <div class='title3'>Editing members of tag range $range_num</div>
                <div class='title4'>The search criteria previously used to create this tag range has been loaded in the filter area.<br><br>
                To change the members of this tag range, make changes to the selection criteria.<br>
                When done, click the Submit button on the bottom left.<br>
                Click the Cancel button to leave the editor without making changes.</div><br><br>
                <div class='data'>Tag Details:<br>
                    Tag: $display_name<br>
                    Dates: $start - $end<br>
                    $prettyRowCount<br>
                    
                
            </div>
        ";
        }else $html="Error loading range details for $range_num";
        
        
    }else $html="Error.  Range_num not passed.";
    
    return $html;
}
function submitTagRangeCriteriaEdit($range_num){
    $html="";

    if($range_num){
        return submitTagEdit("criteriaRange",$range_num);
        
    }else $html="Error.  Range_num not passed.";
    return $html;
}
?>