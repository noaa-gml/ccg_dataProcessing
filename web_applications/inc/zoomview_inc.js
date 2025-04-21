var zoomlevel = 0;
var imageidx = 0;
var zoomfieldnum;
var filenamedelim;
var zoomfielddelim;

function zoomview_ZoomIn()
{
   var newsrc = '';

   switch ( zoomlevel )
   {
      case 0:
         newsrc = imagelevels[1][0];
         zoomlevel = 1;
         imageidx = 0;
         document.getElementById('zoomview_imgsrc').innerHTML = basename(newsrc);
         document.getElementById('zoomview_outimage').src = newsrc;
         break;
      case imagelevels.length - 1:
         break;
      default:
         curfilename = basename(imagelevels[zoomlevel][imageidx]);
         key = new RegExp("^"+curfilename.split(filenamedelim)[zoomfieldnum],'i');

         for ( i=0; i<imagelevels[zoomlevel+1].length; i++ )
         {
            tmpfilename = basename(imagelevels[zoomlevel+1][i]);
            if ( tmpfilename.split(filenamedelim)[zoomfieldnum].match(key) )
            {
               newsrc = imagelevels[zoomlevel+1][i];
               imageidx = i;
               zoomlevel++;
               break;
            }
         }

         document.getElementById('zoomview_imgsrc').innerHTML = basename(newsrc);
         document.getElementById('zoomview_outimage').src = newsrc;
         break;
   }

   zoomview_SetBtns();
}

function zoomview_ZoomOut()
{
   var newsrc = '';

   switch (zoomlevel)
   {
      case 0:
         break;
      case 1:
         newsrc = imagelevels[0][0];
         zoomlevel = 0;
         imageidx = 0;
         document.getElementById('zoomview_imgsrc').innerHTML = basename(newsrc);
         document.getElementById('zoomview_outimage').src = newsrc;
         break;
      default:
         for ( i=0; i<imagelevels[zoomlevel-1].length; i++ )
         {
            curfilename = basename(imagelevels[zoomlevel][imageidx]);
            key = new RegExp("^"+curfilename.split(filenamedelim)[zoomfieldnum].split(zoomfielddelim)[0]+"$",'i');

            tmpfilename = basename(imagelevels[zoomlevel-1][i]);
            if ( tmpfilename.split(filenamedelim)[zoomfieldnum].match(key) )
            {
               newsrc = imagelevels[zoomlevel-1][i];
               imageidx = i;
               zoomlevel--;
               break;
            }
         }

         document.getElementById('zoomview_imgsrc').innerHTML = basename(newsrc);
         document.getElementById('zoomview_outimage').src = newsrc;
         break;
   }

   zoomview_SetBtns();
}

function zoomview_PrevImg()
{
   if ( imageidx > 0 )
   {
      imageidx--;
      newsrc = imagelevels[zoomlevel][imageidx];
      document.getElementById('zoomview_imgsrc').innerHTML = basename(newsrc);
      document.getElementById('zoomview_outimage').src = newsrc;
   }

   zoomview_SetBtns();
}

function zoomview_NextImg()
{
   if ( imageidx < imagelevels[zoomlevel].length - 1)
   {
      imageidx++;
      newsrc = imagelevels[zoomlevel][imageidx];
      document.getElementById('zoomview_imgsrc').innerHTML = basename(newsrc);
      document.getElementById('zoomview_outimage').src = newsrc;
   }   

   zoomview_SetBtns();
}

function zoomview_SetBtns()
{
   switch (zoomlevel)
   {
      case 0:
         document.getElementById('zoomview_zoomin_btn').disabled = false;
         document.getElementById('zoomview_zoomout_btn').disabled = true;
         break;
      case imagelevels.length-1:
         document.getElementById('zoomview_zoomin_btn').disabled = true;
         document.getElementById('zoomview_zoomout_btn').disabled = false;
         break;
      default:
         document.getElementById('zoomview_zoomin_btn').disabled = true;
         document.getElementById('zoomview_zoomout_btn').disabled = true;

         // Check to see if we can zoom in
         curfilename = basename(imagelevels[zoomlevel][imageidx]);
         key = new RegExp("^"+curfilename.split(filenamedelim)[zoomfieldnum],'i');

         for ( i=0; i<imagelevels[zoomlevel+1].length; i++ )
         {
            tmpfilename = basename(imagelevels[zoomlevel+1][i]);
            if ( tmpfilename.split(filenamedelim)[zoomfieldnum].match(key) )
            {
               document.getElementById('zoomview_zoomin_btn').disabled = false;
               break;
            }
         }

         // Check to see if we can zoom out
         if ( zoomlevel == 1 )
         {
            // If we are at the first zoom level, always allow the zoom out
            document.getElementById('zoomview_zoomout_btn').disabled = false;
         }
         else
         {
            for ( i=0; i<imagelevels[zoomlevel-1].length; i++ )
            {
               curfilename = basename(imagelevels[zoomlevel][imageidx]);
               key = new RegExp("^"+curfilename.split(filenamedelim)[zoomfieldnum].split(zoomfielddelim)[0]+"$",'i');
   
               tmpfilename = basename(imagelevels[zoomlevel-1][i]);
               if ( tmpfilename.split(filenamedelim)[zoomfieldnum].match(key) )
               {
                  document.getElementById('zoomview_zoomout_btn').disabled = false;
                  break;
               }
            }
         }

         break;
   }

   if ( imageidx == 0 )
   { document.getElementById('zoomview_prev_btn').disabled = true; }
   else
   { document.getElementById('zoomview_prev_btn').disabled = false; }

   if ( imageidx == imagelevels[zoomlevel].length - 1 )
   { document.getElementById('zoomview_next_btn').disabled = true; }
   else
   { document.getElementById('zoomview_next_btn').disabled = false; }
}

function basename (path, suffix) {
    // http://kevin.vanzonneveld.net
    // +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +   improved by: Ash Searle (http://hexmen.com/blog/)
    // +   improved by: Lincoln Ramsay
    // +   improved by: djmix
    // *     example 1: basename('/www/site/home.htm', '.htm');
    // *     returns 1: 'home'
    // *     example 2: basename('ecra.php?p=1');
    // *     returns 2: 'ecra.php?p=1'
    var b = path.replace(/^.*[\/\\]/g, '');

    if (typeof(suffix) == 'string' && b.substr(b.length - suffix.length) == suffix) {
        b = b.substr(0, b.length - suffix.length);
    }

    return b;
}
