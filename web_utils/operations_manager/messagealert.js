function MessageAlert(mode)
{
if ((navigator.appName.indexOf("Netscape") != -1 && parseInt(navigator.appVersion) < 5) ||
(navigator.appName.indexOf("Microsoft") != -1 && parseInt(navigator.appVersion) < 4))
{ ; return; }

if (mode == 'show') { document.getElementById('messagebox').style.visibility='visible'; }
else { document.getElementById('messagebox').style.visibility='hidden'; }
}
