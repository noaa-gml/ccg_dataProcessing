// Borrowed from:
// http://aspn.activestate.com/ASPN/Cookbook/PHP/Recipe/414334
function php_serialize(obj)
{
    var string = '';
    var count;

    if (typeof(obj) == 'object') {
        if (obj instanceof Array) {
            string = 'a:';
            tmpstring = '';
            count = 0;
            for (var key in obj) {
                tmpstring += php_serialize(key);
                tmpstring += php_serialize(obj[key]);
                count++;
            }
            string += count + ':{';
            string += tmpstring;
            string += '}';
        } else if (obj instanceof Object) {
            classname = obj.toString();

            if (classname == '[object Object]') {
                classname = 'StdClass';
            }

            string = 'O:' + classname.length + ':"' + classname + '":';
            tmpstring = '';
            count = 0;
            for (var key in obj) {
                tmpstring += php_serialize(key);
                if (obj[key]) {
                    tmpstring += php_serialize(obj[key]);
                } else {
                    tmpstring += php_serialize('');
                }
                count++;
            }
            string += count + ':{' + tmpstring + '}';
        }
    } else {
        switch (typeof(obj)) {
            case 'number':
                if (obj - Math.floor(obj) != 0) {
                    string += 'd:' + obj + ';';
                } else {
                    string += 'i:' + obj + ';';
                }
                break;
            case 'string':
                // I could not get JavaScript to recognize that
                // numbered elements in the array passed from PHP
                // to JavaScript are integers instead of strings.

                // Updated this check because strings can be '0123'
                // which should stay as a string and not be an integer
                numkey = /^(0|[1-9][0-9]*)$/
                if ( obj.match(numkey) )
                {
                   string += 'i:' + obj + ';';
                }
                else
                {
                   string += 's:' + obj.length + ':"' + obj + '";';
                }
                break;
            case 'boolean':
                if (obj) {
                    string += 'b:1;';
                } else {
                    string += 'b:0;';
                }
                break;
        }
    }

    return string;
}
