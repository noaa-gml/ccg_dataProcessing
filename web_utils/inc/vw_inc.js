var hreflist = new Array();

function ImageList()
{
   var f = document.mainform;
   var randnum = Math.floor(Math.random()*10000);

   document.getElementById('PrevImg').disabled = false;
   document.getElementById('NextImg').disabled = false;

   if ( f.imagelist.selectedIndex <= 0 )
   { document.getElementById('PrevImg').disabled = true; }
   if ( f.imagelist.selectedIndex == f.imagelist.length - 1 )
   { document.getElementById('NextImg').disabled = true; }

   if ( f.imagelist.selectedIndex > -1 )
   {
      f.plotimg.src = f.imagelist[f.imagelist.selectedIndex].value+'?num='+randnum;
      
      SetHrefList();
   }

}

function ImageNext()
{
   var f = document.mainform;
   var randnum = Math.floor(Math.random()*10000);

   document.getElementById('PrevImg').disabled = false;
   document.getElementById('NextImg').disabled = false;

   if ( f.imagelist.selectedIndex < f.imagelist.length - 1)
   { f.imagelist.selectedIndex++; }

   if ( f.imagelist.selectedIndex == f.imagelist.length - 1 )
   { document.getElementById('NextImg').disabled = true; }

   if ( f.imagelist.selectedIndex < f.imagelist.length )
   {
      f.plotimg.src = f.imagelist[f.imagelist.selectedIndex].value+'?num='+randnum;
      
      SetHrefList();
   }
}

function ImagePrev()
{
   var f = document.mainform;
   var randnum = Math.floor(Math.random()*10000);

   document.getElementById('PrevImg').disabled = false;
   document.getElementById('NextImg').disabled = false;

   if ( f.imagelist.selectedIndex > 0 )
   { f.imagelist.selectedIndex--; }

   if ( f.imagelist.selectedIndex <= 0 )
   { document.getElementById('PrevImg').disabled = true; }

   if ( f.imagelist.selectedIndex > -1 )
   {
      f.plotimg.src = f.imagelist[f.imagelist.selectedIndex].value+'?num='+randnum;

      SetHrefList(); 
   }
}

function SetHrefList()
{
   //
   // Set the href list to the right of the navigation buttons
   //
   var f = document.mainform;

   var ohreflist = top.document.getElementById('hreflist');
   if ( hreflist[f.imagelist.selectedIndex] != '' )
   { ohreflist.innerHTML = hreflist[f.imagelist.selectedIndex]; }
   else
   { ohreflist.innerHTML = ' '; }
}
