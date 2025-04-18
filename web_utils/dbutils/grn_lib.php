<?php
/*GGGRN related functions*/

function grn_SearchCriteria($options=[],$inputOptions=[]){
    /*General function to build criteria selectors for all gggrn data.
        $options are for this function and can override $fullOpts or be empty array.
        $inputOptions are to override defaults for bs_input (styling etc)
    */
    $fullOpts=[#Some layout and content option defaults.  Override in above.
        "project_nums"=>[1,2,3,4,6,34,35],#array(1,2,3,4,6,7,21,22,33,34,35)
    ];
    $fullInpOpts=[
        "labelPos"=>"top",
        "bsLabelSize"=>'4',
        "bsInputSize"=>'8',
        'labelNoWrap'=>true
    ];
    extract(bs_setOptions($fullOpts,$options));#Set default options and overrides into namespace
    $fullInpOpts=bs_setOptions($fullInpOpts,$inputOptions);

    /*Sample options*/
    #site
    $siteInp=grn_siteInput('',$fullInpOpts);

    #Project
    $projInp=grn_projectInput('',$fullInpOpts,false);

    #strategy
    $stratInp=grn_strategyInput('',$fullInpOpts);

    #sample datetimes
    $ev_dateInputs=bs_dateRange('','',[],$fullInpOpts);

    #tag
    $tagInp=grn_tagInput('',$fullInpOpts);

    $inputs=$siteInp.$projInp.$stratInp.$ev_dateInputs.$tagInp."<br><br>";
    $html=bs_getSearchFormWrapper($inputs);
    return $html;
}
function grn_getSelectType($inputOptions){
    /*Utility function to return type of select to use (select or datalist)
    We put it in a function to make it easy to update if datalist becomes problematic.  At the moment,
    it is a better ui because it allows midstring search matching.*/
    if(!$inputOptions['multple'] && $inputOptions['size']==1){
        $type='datalist';
    }else{$type='select';}
    return $type;
}
function grn_siteInput($site_nums='',$inputOptions=[]){
    /*Returns a site selector widget*/
    if(!isset($inputOptions['listData'])){
        bldsql_init();
        bldsql_from("gmd.site");
        bldsql_col("num as 'value'");
        bldsql_col("code as 'abbr'");
        bldsql_col("concat('(',code,') ',name) as 'name'");
        $a=doquery();
        $inputOptions['listData']=$a;
    }

    $type=grn_getSelectType($inputOptions);
#    $inputOptions['maxWidth']='40px';
    $type='filteredAutocomplete';
    $html=bs_input($type,"site_nums","Site",$site_nums,$inputOptions);
    return $html;
}

function grn_projectInput($project_num='',$inputOptions=[],$project_nums=[],$filterList=false){
    /*Returns a project selector widget.
    $project_num is a scalar int/string or an array of int/strings (for multi selects)
    $inputOptions can be any options defined in bs_input().
    Input specific defaults for some are below.
    $project_nums is list of projects to filter select to
    if $filterList we join to tmp table t_filtered_nums caller creates
    */

    $defaultOpts=[
        'addBlankRow'=>true,
        'maxWidth'=>'175px',
        'size'=>-5,
        'multiple'=>true
    ];
    #add in some defaults if not passed
    foreach($defaultOpts as $key=>$val){if(!isset($inputOptions[$key]))$inputOptions[$key]=$val;}

    $type=grn_getSelectType($inputOptions);#set select type

    if(!isset($inputOptions['listData'])){#Allow caller can preselect list if wanted.
        bldsql_init();
        bldsql_from("gmd.project p");
        if($filterList){
            bldsql_from("t_filtered_nums f");
            bldsql_where("p.tag_num=f.tag_num");
        }
        bldsql_col("p.num as 'value'");
        if($type=='dataList'){
            bldsql_col("abbr as 'abbr'");
            bldsql_col("name as 'name'");
        }else bldsql_col("abbr as 'name'");
        if($project_nums)bldsql_wherein("num in",$project_nums);

        $a=doquery();
        $inputOptions['listData']=$a;
    }

    $html=bs_input($type,"project_num","Project",$project_num,$inputOptions);

    return $html;
}
function grn_strategyInput($strategy_num='',$inputOptions=[]){
    /*Returns a strategy selector widget.
    $strategy_num is a scalar int/string or an array of int/strings (for multi selects)
    $inputOptions can be any options defined in bs_input().
    Input specific defaults for some are below.*/

    $defaultOpts=[
        'addBlankRow'=>true,
        'maxWidth'=>'175px',
        'size'=>-4,
        'multiple'=>true
    ];

    foreach($defaultOpts as $key=>$val){if(!isset($inputOptions[$key]))$inputOptions[$key]=$val;}#Set defaults
    if(!$inputOptions['multple'] && $inputOptions['size']==1){
        $type='datalist';
    }else{$type='select';}

    if(!isset($inputOptions['listData'])){#Allow caller can preselect list if wanted.
        bldsql_init();
        bldsql_from("ccgg.strategy");
        bldsql_col("num as 'value'");
        if($type=='dataList'){
            bldsql_col("abbr as 'abbr'");
            bldsql_col("name as 'name'");
        }else bldsql_col("abbr as 'name'");

        $a=doquery();
        $inputOptions['listData']=$a;
    }

    $html=bs_input($type,"strategy_num","Strategy",$strategy_num,$inputOptions);
    return $html;
}
function grn_tagInput($selectedTagNum='', $inputOptions=[],$filterList=false){
    /*Returns a tag selector widget.
    $inputOptions can be anything defined in bs_input(). Some are defaulted below;
    if $filterList we join to tmp table t_filtered_nums caller creates
    */
    if(!isset($inputOptions['listData'])){
        bldsql_init();
        bldsql_from("ccgg.tag_view v");
        if($filterList){
            bldsql_from("t_filtered_nums f");
            bldsql_where("v.tag_num=f.tag_num");
        }
        bldsql_col("v.tag_num as 'value'");
        #bldsql_col("concat(internal_flag,'[',tag_num,']') as 'abbr'");
        bldsql_col("concat(case when v.parent_tag_num>0 then '&nbsp;&nbsp;&nbsp;' else '' end,v.display_name) as 'name'");
        bldsql_col("v.group_name");
        bldsql_col("case when v.reject=1 then 'Rej' when v.selection=1 then 'Sel' when v.information=1 then 'Info' else '' end as group_name2");
        bldsql_orderby("v.sort_order");
        bldsql_where("v.deprecated=0");
        if($selectedTagNum){
            #Make sure selected tag in the list
               #[not sure best way to do this...]
        }

        $a=doquery();

        $inputOptions['listData']=$a;
    }
    $inputOptions['searchboxDisplayType']='textarea';
    $inputOptions['searchWindowTitle']='Tag Selection';
    $inputOptions['group1ColLabel']="Type";
    $inputOptions['group2ColLabel']="Severity";
    $inputOptions['size']='40';

    $html=bs_input("filteredAutocomplete","tag_num","Tag",$selectedTagNum,$inputOptions);
    return $html;
}

?>
