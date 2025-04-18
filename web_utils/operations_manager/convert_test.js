function Dec2Deg(deg,type)
{
        var abv, min;
        var v_f = parseFloat(deg);
        var v_i = parseInt(deg);

        abv = Math.abs(v_f);
        deg = Math.abs(v_i);
        min = parseInt((abv-deg)*60);

        var h;
        switch(type)
        {
        case 'lat':
                h = (v_f >= 0) ? 'N' : 'S';
                break;
        case 'lon':
                h = (v_f >= 0) ? 'E' : 'W';
                break;
        }
        return deg+' '+min+h;
}

function Deg2Dec(v)
{
        a = v.split(/\s+/);
        z = a[1].toLowerCase();
        h = z.substr(z.length-1,1);
        min = parseInt(z.substr(0,z.length-1));
        deg = parseInt(a[0]);

        if ((h == 's' || h == 'n') && deg > 90) return -99.99;
        if ((h == 'e' || h == 'w') && deg > 180) return -999.99;

        sign = (h == 's' || h == 'w') ? -1 : 1;
        return (sign*(deg + min/60)).toFixed(3);
}

function ConvertCB()
{
   var f = document.mainform;

   //alert(f.ev_lat.value);

   lat = Dec2Deg(f.ev_lat.value,'lat');
   alert(lat);

   lat = Deg2Dec(lat);
   alert(lat);

}
