/*Various js utility functions*/
var bs_tableClickedDestDiv='';//set in bs_indexInclude.php, defaults to 'other' main div from searchFormDest.  Used to call below and can be overriden in php bs_table()
function bs_tableClicked(rowID,doWhat,destDiv,includeSideBarForm = false,bs_param1='', bs_param2='', bs_param3='',tableID=''){
    /*Handler for the bs_table() output wrapper.  does a get to switch.php passing left search_form inputs along with bs_params1/2
    Results put into destDiv.  See bs_table() for details on how this is used.*/
    //Format any data to pass.

    bs_showTableRowClicked(tableID,rowID);

    let params='doWhat='+doWhat;let formID='';
    if(bs_param1){params+="&bs_param1="+bs_param1;}
    if(bs_param2){params+="&bs_param2="+bs_param2;}
    if(bs_param3){params+="&bs_param3="+bs_param3;}
    if(includeSideBarForm){formID='bs_sideBarForm';}
    let data=bs_getFormData(formID,params);

    //Make call
    bs_get(data,destDiv);

}
function bs_showTableRowClicked(tableID,rowID){
/*Removes highlighting from all(!) displayed tables and then highlights selected row.  This may need to limit to selected table.
If changing, be sure to edit bs_table() php func.*/

    bs_removeClass("#"+tableID+" tr.bs_tableRow","table-active");
    bs_addClass("#"+rowID,"table-active");
}
function bs_getEl(idName){
    /*Return the element object for passed id*/
    return document.getElementById(idName);
}
function bs_hide(selector){
    /*Hide passed element selector (all matches).
        class: .className
        id: #idName
    */
      var elements = document.querySelectorAll(bs_escSelector(selector));
      elements.forEach(function(element) {
        element.style.display = 'none';
      });
}
function bs_escSelector(selector){
    /*Return an escaped selector for passed css selector.  Only escape id and class selectors.*/
    // Split the selector into components
    const parts = selector.split(' ');
    const safeParts = parts.map((part) => {
        if (part.startsWith('#')) {
            // Escape ID selectors (#...)
            return `#${CSS.escape(part.slice(1))}`;
        } else if (part.startsWith('.')) {
            // Escape class selectors that start with a dot (.)
            return `.${CSS.escape(part.slice(1))}`;
        } else {
            // Return other parts (e.g., tags, attributes) as-is
            return part;
        }
    });


    // Reassemble the selector
    const safeSelector = safeParts.join(' ');
    //console.log(selector,safeSelector);
    return safeSelector;
}
function bs_show(selector){
    /*Show passed element selector (all matches).
        class: .className
        id: #idName
    */
      var elements = document.querySelectorAll(bs_escSelector(selector));
      elements.forEach(function(element) {
        element.style.display = '';
      });
}
function bs_disable(selector,disable=true){
    /*Disable/Enable passed element selector (all matches).
        class: .className
        id: #idName
    */
      var elements = document.querySelectorAll(bs_escSelector(selector));
      elements.forEach(function(element) {
        element.disabled = disable;
        console.log("disabling "+selector+":"+disable);
      });
}
function bs_addClass(selector,className){
    /*Add className from element selector (all matches).
        class: .className
        id: #idName
    */
    var elements = document.querySelectorAll(bs_escSelector(selector));
    elements.forEach(function(element) {
        element.classList.add(className);
    });
}
function bs_removeClass(selector,className){
    /*Remove className from element selector (all matches).
        class: .className
        id: #idName
    */
    var elements = document.querySelectorAll(bs_escSelector(selector));
    elements.forEach(function(element) {
        element.classList.remove(className);
    });
}
function bs_setHTML(divID,html){
    /*Set html into divID*/
    const el=bs_getEl(divID);
    if(!el){console.log("Element not defined:"+divID+" while setting html:"+html);}
    else{el.innerHTML=html;}
}
function bs_getHTML(divID){
    /*Returns el's html*/
    const el=bs_getEl(divID);
    return el.innerHTML;
}
function bs_fireEvent(id,event='change'){
    /*Fire event on id*/
    const el=bs_getEl(id);
    if(el){
        ev=new Event(event);
        el.dispatchEvent(ev);
    }
}

/*Form utilities*/
function bs_getFormData(formID='',parameters=''){
    //Combines fields in form and parameters into a FormData object to be passed using fetch.
    //Both are optional and can be blank or null.
    //Paremeters are in the form of a query string, ex: 'doWhat=bs_loadList&bs_param1=1&bs_param2=2'

    let formData=false;
    if(formID){
        form=document.getElementById(formID);
        formData=new FormData(form);
    }else{ formData=new FormData();}
    if(parameters){
        var searchParams = new URLSearchParams(parameters);
        for (var pair of searchParams.entries()) {
            formData.append(pair[0], pair[1]);
        }
    }
    return formData;
}

function bs_logFormData(formData){
    for (var pair of formData.entries()) {
        console.log(pair[0]+ ', ' + pair[1]);
    }
}
  ////!!!!!this not right yet.  not sure on the model here.
  //...switched to below processForm.  Leaving for doc for now..
function bs_processedForm(formID,callback=''){
    /*Add this form to validation and ajax submit logic
        Form must have a doWhat hidden input.
    */
    let form=document.getElementById(formID);
    form.addEventListener('submit', function (event) {
        event.preventDefault();
        event.stopPropagation();
        if (!form.checkValidity()) {
            alert("Fix errors");

        }else{

            let formData=bs_getFormData(formID);
            bs_post(formData,'dest');
            form.classList.add('was-validated');
        }
    });
}
function bs_processForm(formID, doWhat, destDiv){
    /*Do validation checks, gather data and submit via post
        target Form id
        doWhat is the switch.php action to take
        destDiv is where to send results.  Can use bs_ajaxJSDiv (which is hidden)
            for pure js response (like popups, set status text & clear form area or similar)
    */
    if(formID){
        let form=document.getElementById(formID);
        if (!form.reportValidity()) {
            bs_setStatusMssg("Please correct invalid form entries");
            return false;
        }
    }

    //Gather data to submit.  Pass formID so handler can re-enable buttons if needed.
    let formData=bs_getFormData(formID,'doWhat='+doWhat+"&formID="+formID);//Must get before clearing.

    //Disable all form buttons with formID_btn set as class (submit, delete,...)
    bs_disable("."+formID+"_btn");

    //Clear destination contents
    bs_setHTML(destDiv,'');

    //bs_logFormData(formData);
    bs_post(formData,destDiv);
    //form.classList.add('was-validated');

}
function bs_addRecord(table,destDiv,modal){
    /*Post add to switch.php->bs_addRecord
        modal is 1 or 0
        See php bs_addRecord() for details.
    */
    //console.log(modal);
    let formData=bs_getFormData('','doWhat=bs_addRecord&bs_addRecordIsModal='+modal+'&bs_processedTable='+table);//Must get before clearing.
    bs_setHTML(destDiv,'');
    bs_post(formData,destDiv);
}
var bs_searchFormDestDiv='';//set in bs_indexInclude.php/index.php configs for site
function bs_submitSearchForm(doWhat='bs_loadList',destDiv=bs_searchFormDestDiv){
    /*Submit main search_form.
        destDiv is where to put the returned content, generally bs_adjContentDiv or bs_fixedContentDiv
        bs_loadList must be configured in switch.php.
    */
    //Clear main content divs
    bs_clearContentDivs();

    //Submit form
    bs_processForm('search_form',doWhat,destDiv);

}
function bs_confirmDelete(table,pkey,text){
    /*Util function to verify form delete action and set var for processing
        Returns true if user confirms, false otherwise
    */
    if(confirm(text)){
        el=bs_getEl("delete_"+table);
        if(el){
            el.value=pkey;
            return true;
        }else{alert("error, couldn't find delete input for "+table);}
    }
    return false;
}
/*Index and switch utils*/

function bs_clearContentDivs(){
    bs_setHTML('bs_adjContentDiv','');
    bs_setHTML('bs_fixedContentDiv','');
}

function bs_setStatusMssg(mssg,ms=3000){
    /*Set message into the return status div in the bottom right of footer.  Intended
    to be return status from post or get.  Self clears after a bit.*/
    bs_setHTML('bs_statusDiv',mssg);
    setTimeout(function(){
        bs_setHTML('bs_statusDiv','&nbsp;');
    },ms);
}

function bs_elementSubmitsSearchForm(id,destDiv=bs_searchFormDestDiv){
    /*Sets up passed element id to autosubmit search form
        bs_searchFormDestDiv is set in bs_indexInclude.php/index.php configs
    */
    const el=bs_getEl(id);
    el.addEventListener('change', function(event) {
        bs_submitSearchForm('bs_loadList',destDiv);

    });
}
function bs_searchEveryThing(){
    /*Submits the search everything search*/
    bs_submitSearchForm();
    var el=bs_getEl('searchEverythingTerm');
    el.value='';//Reset so that it doesn't stick around if user changes other criteria
}
function bs_elementReloadsSearchForm(id){
    /*Sets up passed element id to autosubmit search form and reload using selected values.
        switch.php must have bs_reloadSearchForm dowhat handler.

    */

    const el=bs_getEl(id);
    el.addEventListener('change', function(event) {
        //setTimeout(function(){
            bs_submitSearchForm('bs_reloadSearchForm','bs_leftContentDiv');
        //},100);
    });

}

/*UI & form element utils*/

function bs_dataList(arr) {
    /*Autocomplete widget support using datalists
        Assumes setup from php side.
        arr is an associative array with following keys:
            id=>[input id] id of hidden input that will ultimately get submitted, ex site_num
            values=>array of valuess.  selected value will get set into above input
            names=>array of corresponding names.  We use names even though we could build array from datalist obj because I couldn't
                find if order was gaurenteed.
                const datalistOptions = Array.from(inputElement.list.options).map(option => option.value);
            shortNames=>optional array of abbrs to use as the displayed/selected value
        {id} is hidden input that will receive value
        {id}_display is tied to datalist and receives the selection. Note; you can use display text (<option>text</option>)
            in datalist, but value of option is what gets set
    */
    const id=arr['id'];
    const el=bs_getEl(id);
    const disp_el=bs_getEl(id+"_display");

    disp_el.addEventListener('change', function(event) {
        const inputValue = event.target.value;
        let i = arr['names'].indexOf(inputValue);//Note datalist does case insensitive matching and if user selects an entry it will be an exact match here
        if (i==-1) i= arr['shortNames'].map(abbr=>abbr.toLowerCase()).indexOf(inputValue.toLowerCase());//Do a case insensitive match against abbr column too (if needed). this lets user type mlo tab without having to select entry

        if (i==-1) {//no match
            disp_el.value = ''; // Clear the input if it's not a valid option
            el.value='';
        }else{//matched
            el.value=arr['values'][i];
            if(arr['shortNames'] && typeof arr['shortNames'][i] !== 'undefined'){disp_el.value=arr['shortNames'][i];}//If shortname passed, then set as display
            //else{disp_el.value=arr['names'][i];}
            console.log(el.value+" selected: "+arr['names'][i]);
        }
    });

}
function bs_showModal(divID,removeOnHide=false){
    //Show passed modal
    //If removeOnHide, we destroy and remove from the dom.
    var el=bootstrap.Modal.getOrCreateInstance('#'+divID);
    el.show();

    //Add a listener so we can destroy
    if(removeOnHide){
        el._element.addEventListener('hidden.bs.modal', function(e){
            el._element.remove();
        });
    }
}
function bs_hideModal(divID=''){
    //Hide modal window if exists.  If divID='', we close any modal with class 'bs_modal_hidable'.  See php bs_modal() for details.
    if(divID==''){selector='.bs_modal_hidable';}
    else {selector="#"+divID;}
    var elements = document.querySelectorAll(bs_escSelector(selector));
    elements.forEach(function(element) {
        var el=bootstrap.Modal.getInstance('#'+element.id);//Need the bootstrap instance
        if(el){el.hide();}
    });

}
function bs_filteredAutocompleteSelected(rowID,targID,p1,p2,p3){
    //Handler for when a filtered autocomplete is selected
    //Assumes naming convention (see bs_input).
    const el=bs_getEl(targID);
    const disp=bs_getEl(targID+"_display");
    el.value=p1;//Selected value
    disp.value=p2;//Selected text
    disp.setAttribute("title",p2);//Set title/popover
    bs_hideModal('');//clear screen of modal window.
}
function bs_searchTable(inputID){
    //Similar to php bs_searchEverything but clientside search of html table, highlights matches and hides others.
    //There is a default text box search input (inputID) and 2 optional group selects
    //We'll do 'and' search, so all selections must match for row to show
    //Assumes naming convention, see php->bs_input() for details
    //console.time('Search Execution Time');
    var phrase = "";
    var table = bs_getEl(inputID+"_table");
    var rows = table.getElementsByTagName("tbody")[0].getElementsByTagName("tr");
    var firstRow=false;//Track first resultset row to scroll to.

    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];
        var rowText = row.textContent.toLowerCase();
        var hasMatch0 = true;var hasMatch1=true;var hasMatch2=true;//default true so can handle optional columns

        // Loop through each cell in the row.  Assume order is main text col (inputID search) and optional: group1 (_group), group2 (_group2)
        for (var j = 0; j < row.cells.length; j++) {
            var cell = row.cells[j];
            var cellText = cell.textContent;

            // Reset cell HTML with un-markedup text to remove any previous highlights/searchs
            cell.innerHTML = cellText;

            // Check for partial matches.  Load phrase from linked search widget
            if(j==0){phrase=bs_getEl(inputID).value;}
            if(j==1){phrase=bs_getEl(inputID+"_group").value;}
            if(j==2){phrase=bs_getEl(inputID+"_group2").value;}

            if(phrase!=""){
                //Do a case insensitive string match allowing * for wildcard.  Highlight matches.
                let escapedPattern = phrase.split('*').map(part => part.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('.*');
                var regex = new RegExp(`(${escapedPattern})`, 'i');

                if (regex.test(cellText)) {
                    cell.innerHTML = cellText.replace(regex, function (match) {
                        return '<span class="bs_textHighlightB">' + match + '</span>';
                    });
                }else{
                    if(j==0){hasMatch0=false;}
                    if(j==1){hasMatch1=false;}
                    if(j==2){hasMatch2=false;}
                }
            }else if(j>0){//Try for match of typed text other cells for flexible search if not filtered by select
                phrase=bs_getEl(inputID).value;
                //Do a case insensitive string match allowing * for wildcard.  Highlight matches.
                let escapedPattern = phrase.split('*').map(part => part.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('.*');
                var regex = new RegExp(`(${escapedPattern})`, 'i');

                if (regex.test(cellText)) {
                    hasMatch0=true;
                    cell.innerHTML = cellText.replace(regex, function (match) {
                        return '<span class="bs_textHighlightB">' + match + '</span>';
                    });
                }
            }
        }

        // Display row if all selected filters matched.
        if (hasMatch0 && hasMatch1 && hasMatch2) {
            row.style.display = "";
            if(firstRow===false){firstRow=row.id;}

        } else {
            row.style.display = "none";
        }
        if(firstRow !== false){//If any rows matched, highlight the first and scroll into view
            //bs_showTableRowClicked(inputID+"_table",firstRow);
            bs_getEl(firstRow)?.scrollIntoView({
                    behavior: 'smooth', // Smooth scrolling
                    block: 'center'     // Scroll to center of the view
            });
        }
    }
    //console.timeEnd('Search Execution Time');
}

function bs_wildcardMatch(str, pattern) {
    //Simple case insensitive string match that allows * wildcard
    // Escape the wildcard character to use in the regex
    const escapedPattern = pattern.split('*').map(part => part.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('.*');

    // Create a regex with case-insensitive flag
    const regex = new RegExp(`${escapedPattern}`, 'i'); // Use ^ and $ for full string match
    return regex.test(str);
}

/*Autocomplete widget*/
// Function to trigger search with a delay
var bs_autocompleteSearchTimeouts={};//globals to store instance variables
var bs_autocompleteCurrentIndexes={};

function bs_autocompleteDynamicSearch(searchBoxID, searchBoxTimeoutMS) {
    // Clear previous timeout if a new keypress happens before $searchBoxTimeoutMS ms
    if(searchBoxID in bs_autocompleteSearchTimeouts){
        if(bs_autocompleteSearchTimeouts[searchBoxID]){
            clearTimeout(bs_autocompleteSearchTimeouts[searchBoxID])
        }
    }

    // Set a new timeout for the search function to run after $searchBoxTimeoutMS seconds
    bs_autocompleteSearchTimeouts[searchBoxID] = setTimeout('bs_searchTable(\"'+searchBoxID+'\")', searchBoxTimeoutMS);
}
function bs_initAutocomplete(searchBoxID,searchBoxTimeoutMS){
    //See php bs_input for documentation
    //Set some variable names that are defined in the php func
    let modalID=searchBoxID+"_modal";
    let tableID=searchBoxID+"_table";
    let group1ID=searchBoxID+"_group";
    let group2ID=searchBoxID+"_group2";

    bs_autocompleteSearchTimeouts[searchBoxID]='';//Init global instance cache
    bs_autocompleteCurrentIndexes[searchBoxID]=0;//Init and default to 0

    //Set focus in search box and scroll to selected row (if appropriate)
    //Need to use special logic for bootstrap modal..
    bs_getEl(modalID).addEventListener('shown.bs.modal', () => {
      document.querySelector('.bs_tableRow.table-active')?.scrollIntoView({
                        behavior: 'smooth', // Smooth scrolling
                        block: 'center'     // Scroll to center of the view
                    });
      bs_getEl(searchBoxID).focus();
    });



    bs_getEl(searchBoxID).addEventListener('input', () => {
        bs_autocompleteDynamicSearch(searchBoxID,searchBoxTimeoutMS); // Trigger on input with delay
    });

    // Also trigger the search instantly when the user presses the 'Tab' key
    bs_getEl(searchBoxID).addEventListener('keydown', function (event) {
        let currentIndex=bs_autocompleteCurrentIndexes[searchBoxID];//current/last position
        if (event.key === 'Tab') {
            event.preventDefault(); // Prevent the default tab behavior
            bs_autocompleteDynamicSearch(searchBoxID, 1);//Clear and start seach instantly

        }else if (event.key === 'ArrowDown' || event.key ==='ArrowUp') {
            event.preventDefault();
            //console.log(currentIndex);
            const rows = bs_getEl(tableID).getElementsByTagName('tbody')[0].getElementsByTagName('tr');

            if(event.key === 'ArrowDown' ){
                // Increment the currentIndex
                currentIndex++;

                // Skip hidden rows
                while (currentIndex < rows.length && rows[currentIndex].style.display === 'none') {
                    currentIndex++;
                }
                // If we go past the last visible row, wrap around
                if (currentIndex >= rows.length) {
                    currentIndex = 0; // Reset to first row
                    while (currentIndex < rows.length && rows[currentIndex].style.display === 'none') {currentIndex++;}
                }
            }else{
                // Decrement the currentIndex
                currentIndex--;

                // Skip hidden rows
                while (currentIndex >= 0 && rows[currentIndex].style.display === 'none') {
                    currentIndex--;
                }
                // If we go past the first visible row, wrap around
                if (currentIndex < 0) {
                    currentIndex = rows.length - 1; // Reset to last row
                    while (currentIndex >= 0 && rows[currentIndex].style.display === 'none') {currentIndex--;}
                }
            }
            bs_showTableRowClicked(tableID,rows[currentIndex].id);
            rows[currentIndex].scrollIntoView({
                behavior: 'auto', // Smooth scrolling
                block: 'center'     // Scroll to center of the view
            });

        }else if (event.key === 'Enter') {
            event.preventDefault();
            const rows = bs_getEl(tableID).getElementsByTagName('tbody')[0].getElementsByTagName('tr');

            // If the currentIndex is valid, trigger selection logic
            if (currentIndex >= 0 && currentIndex < rows.length && rows[currentIndex].style.display !== 'none') {
                rows[currentIndex].click();//Simulate a click event on the highlighted row
            }
        }
        //Set currentIndex into cached obj
        bs_autocompleteCurrentIndexes[searchBoxID]=currentIndex;
    });

    //Add listeners for optional group selects if there
    g1=bs_getEl(group1ID);
    if(g1){
        g1.addEventListener('change', function (event) {
            event.preventDefault(); // Prevent the default tab behavior
            bs_autocompleteDynamicSearch(searchBoxID, 1);//Clear and start seach instantly
        });
    }
    g2=bs_getEl(group2ID);
    if(g2){
        g2.addEventListener('change', function (event) {
            event.preventDefault(); // Prevent the default tab behavior
            bs_autocompleteDynamicSearch(searchBoxID, 1);//Clear and start seach instantly
        });
    }

}

/*Dygraph plotting*/

function dg_size(innerDivID){
    /*Sets dygraph (dg_) container wrappers to 100% of available.  This is needed because
    Dygraph can't figure out it's size from a parent with a percentage.  bs_plot
    calls this after plotting with an initial set size and then on a timeout so
    that all the layout is completed.  Se bs_plot() for details*/
    // Fetch div elements
    const innerDiv = bs_getEl(innerDivID);
    const optionsDiv=bs_getEl(innerDivID+"_options");
    const oh=optionsDiv.getBoundingClientRect().height;//If options are present, we'll reduce the height by that amount
    //const yLabelDiv=bs_getEl(innerDivID+"+_yLabel");
    //const lw=yLabelDiv.getBoundingClientRect().width;

    innerDiv.style.width = '100%';//`calc(100% - ${lw}px)`;//
    innerDiv.style.height = `calc(100% - ${oh}px)`;
}
//special handler for dygraph plots that have a custom y axis so that double click resets to custom not full
//This isn't perfect.  If dblckicked after manual y set, reverts to out with number still in the y box.
const dg_doubleClickZoomOutPlugin = {
        activate: function(g) {
          // Save the initial y-axis range for later.
          //const initialValueRange = g.getOption('valueRange');//This didn't actually work, wasn't in scope.  Weird because this is the site's example code.
          //console.log(initialValueRange);
          return {
            dblclick: e => {
              var range = g.getOption('valueRange');
              e.dygraph.updateOptions({
                dateWindow: null,  // zoom all the way out
                valueRange: range  // zoom to a specific y-axis range.
              });
              //console.log("initialValueRange:");console.log(range);
              e.preventDefault();  // prevent the default zoom out action.
            }
          }
        }
      }

function bs_saveDivImg(divID,fileName='plot.png'){

    /*Save  div as an image.  Intended for dygraph plots, but should be usable for other divs*/
    // Get the div element
    //const content = document.getElementById(divID);

    // Create a canvas element
    //
    /*const canvas = document.querySelector("#"+divID+" canvas");
    if (canvas) {
        // Convert canvas to data URL
        const dataURL = canvas.toDataURL("image/png");

        // Create a link element
        const link = document.createElement("a");
        link.download = fileName;
        link.href = dataURL;

        // Simulate clicking the download link
        link.click();

    }else{
        alert("Unable to load plot image.");
    }*/
    /*const canvas = document.createElement('canvas');
    canvas.toDataURL("image/png");

    canvas.width = content.offsetWidth;
    canvas.height = content.offsetHeight;

    // Get the canvas 2d context
    const context = canvas.getContext('2d');

    // Draw the content of the div onto the canvas
    context.drawWindow(content, 0, 0, content.offsetWidth, content.offsetHeight, 'rgb(255, 255, 255)');

    // Convert the canvas to a data URL
    const dataURL = canvas.toDataURL();

    // Create a link element
    const link = document.createElement('a');
    link.download = fileName;
    link.href = dataURL;

    // Simulate clicking the download link
    link.click();
    */
}
// Function to save Dygraph plot as PNG
const dg_saveAsPng  = (divID, dygraph, filename='plot.png' ) => {
    // Get Dygraph container
    const container = document.getElementById(divID);

    if (container && dygraph) {
        // Create a new canvas element
        const canvas = document.createElement("canvas");
        canvas.width = container.offsetWidth;
        canvas.height = container.offsetHeight;

        // Get 2D context of the canvas
        const ctx = canvas.getContext("2d");

        // Draw Dygraph plot onto the canvas
        const dygraphCanvas = container.querySelector("canvas");
        ctx.drawImage(dygraphCanvas, 0, 0);

        // Overlay title and axis labels
        ctx.font = "14px Arial";
        ctx.fillStyle = "black"; // Set text color to black
        ctx.fillText(dygraph.getOption('title'), 10, 20);  // Get title from Dygraph instance
        ctx.fillText(dygraph.getOption('labels')[1], 10, canvas.height - 10);  // Get X-axis label from Dygraph instance

        // Convert canvas to data URL
        const dataURL = canvas.toDataURL("image/png");

        // Create a link element
        const link = document.createElement("a");
        link.download = filename;
        link.href = dataURL;

        // Simulate clicking the download link
        link.click();

        // Delay the blur to avoid focus styling
        setTimeout(() => {
            link.blur();
        }, 100); // 100 milliseconds delay

        // Remove temporary canvas
        canvas.remove();
    } else {
        alert("Dygraph container or instance not found!");
    }
};
