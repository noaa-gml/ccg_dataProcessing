function getRadioValue(radioObj)
{
   //
   // This function was found at:
   // http://www.somacon.com/p143.php
   //
   if(!radioObj)
      return "";
   var radioLength = radioObj.length;
   if(radioLength == undefined)
      if(radioObj.checked)
         return radioObj.value;
      else
         return "";
   for(var i = 0; i < radioLength; i++) {
      if(radioObj[i].checked) {
         return radioObj[i].value;
      }
   }
   return "";
}

function setRadioValue(radioObj, newValue)
{
   //
   // This function was found at:
   // http://www.somacon.com/p143.php
   //
   if(!radioObj)
      return;
   var radioLength = radioObj.length;
   if(radioLength == undefined) {
      radioObj.checked = (radioObj.value == newValue.toString());
      return;
   }
   for(var i = 0; i < radioLength; i++) {
      radioObj[i].checked = false;
      if(radioObj[i].value == newValue.toString()) {
         radioObj[i].checked = true;
      }
   }
}

function getSelectValue(selectObj)
{
   if ( !selectObj )
      return;
   var selectLength = selectObj.length;
   if(selectLength == undefined)
      if(selectObj.selected)
         return selectObj.value;
      else
         return "";
   for(var i = 0; i < selectLength; i++) {
      if(selectObj[i].selected) {
         return selectObj[i].value;
      }
   }
   return "";
   
}

function setSelectValue(selectObj, newValue)
{
   if(!selectObj)
      return;
   var selectLength = selectObj.length;
   if(selectLength == undefined) {
      selectObj.selected = (selectObj.value == newValue.toString());
      return;
   }
   for(var i = 0; i < selectLength; i++) {
      selectObj[i].selected = false;
      if(selectObj[i].value == newValue.toString()) {
         selectObj[i].selected = true;
      }
   }
}
