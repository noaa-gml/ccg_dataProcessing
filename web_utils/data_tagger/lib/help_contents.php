<?php
$help=array();
$help['Data Selection']="Use the criteria fields to select the data you want to add tags for.<br>
<ul>
    <li>The selection criteria used determine whether a tag will apply to the sample (flask event) or to individual measurement records.
        <ul>
            <li>If you filter by sample criteria only (eg event #, site,sample date, strategy...), new tags will apply to the sample.</li>
            <li>If you add any analysis criteria (species, program, inst..), the tags will only apply to selected measurements.</li>
        </ul></li>
    <li>If a tag is applied to a sample event, it will automatically be applied to all current and future measurements.</li>
    <li>If it is applied to a measurement record, the tag only applies to that measurement.</li>
    <li>When an event number or data number is used to select, some related criteria is disabled.</li>
    <li>You can multiple event or data numbers in a comma separated list</li>
    <li>The number of applicable filters is displayed in the header for each section.</li>
</ul>
";

$help['Parameter Selection']="You can select one or more parameters.  Use ctrl+click to select multiple.<br>
Paramters are order by the ccgg 6, then alphabetical.  To jump ahead, click a row then start typing the parameter.
";
$help['Aircraft Reset']="Because the aircraft section has pre-built filters (gases, program...) included in the queries, you probably want to remove any event and data filters before starting to avoid unexpected results.<br>
        You can of course further filter the results by selecting sample and analysis filters as well, ie - by limiting to a specific site<br>";

$help['Data']="

    <li>Search results will display on the bottom right of the screen.
        <ul><li>Columns displayed will depend on whether sample criteria or analysis criteria was selected.</li>
    </li>
    <li>All tags for any of the selected data will display above the results area with the (# of rows) next to each flag.</li>
    <li>Tags are ordered by Collection Issues, Measurement Issues and then Selection issues.</li>
    <li>Next to the tag list is a visual timeline of the tags, also ordered from top to bottom by collection, measurement and selection issues.</li>
    <li>Move the mouse over the start/end dates on the graph to see a summary.  Click to see details.
    <li>Use the New Tag button to add a tag for the entire current selection.</li>
    <li>Select a row from the search results to see tags for that specific event/measurement.  If a single event/measurement is selected, the 'New Tag' button only applies to that event/measurement.</li>
    <li>When viewing measurements and the 'Plot results' checkbox is checked, up to 10 paramters will be graphed.  You can click individual
    data points to edit single measurements.</li>
    <li>Tags in can be viewed/edited by selecting the row.</li>
    <li>Tags with grey font are 'preliminary'.  Preliminary tags can be selected in the 'Existing tags' filter section..
    <li>Selecting a tag loads the range details.</li>

";
$help['Tag Details']="
<ul>
    <li>Click Edit tag to directly edit details of the tag range.  Changes are comitted to ALL attached events/measurements.</li>
    <li>When adding comment, comments are stamped with user name and date/time.  In 'edit' mode, no stamp is added.</li>
    <li>Deleting a tag deletes it from ALL events/measurements.  Use with caution.
    <li>The description above the form will tell you the number of affected sample/measurements.
    <li>Use the 'Edit Range Criteria' button to change the criteria used to select the range members.
    
</ul>
";
$help['Date Fields']="
Date fields accept date and optionally, time.
Examples:
<table>
    <tr><td colspan='3'><b>m/d/y</b></td></tr>
    <tr><td>'4/15/14'</td><td>&rarr;</td><td>2014-04-15</td></tr>
    <tr><td>'4-15-2014 2p'</td><td>&rarr;</td><td>2014-04-15 14:00:00</td></tr>
    <tr><td>'4.12.2001 2:38:04'</td><td>&rarr;</td><td>2001-04-12 2:38:04</td></tr>
    <tr><td colspan='3'><b>yyyy-m-d</b></td></tr>
    <tr><td>'2008-12-31'</td><td>&rarr;</td><td>2008-12-31</td></tr>
    <tr><td>'20081231'</td><td>&rarr;</td><td>2008-12-31</td></tr>
    <tr><td>'20081231 2:35a'</td><td>&rarr;</td><td>2008-12-31 2:35:00</td></tr>
    <tr><td colspan='3'><b>Shortcuts(from field)</b></td></tr>
    <tr><td>'2010-11'</td><td>&rarr;</td><td>2010-11-01</td></tr>
    <tr><td>'2010'</td><td>&rarr;</td><td>2010-01-01</td></tr>
    <tr><td>'4/15'</td><td>&rarr;</td><td>2015-04-15</td></tr>
    <tr><td colspan='3'><b>Shortcuts(to field)</b></td></tr>
    <tr><td>'2010-11'</td><td>&rarr;</td><td>2010-11-30</td></tr>
    <tr><td>'2010'</td><td>&rarr;</td><td>2010-12-31</td></tr>
    <tr><td>'4/15'</td><td>&rarr;</td><td>2015-04-15</td></tr>
</table>

";
?>