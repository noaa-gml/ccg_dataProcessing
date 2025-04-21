<script language="javascript" type="text/javascript">


function changeCriteria() {

        num=document.asearchForm.dbe_numcriteria.value;
        var table = document.getElementById("asearchTable"); // find table to append to
        var tbody = table.tBodies[0];
        nrows = tbody.rows.length;

        if (nrows > num) {
                ndel = nrows - num;
                for (var i=0; i<ndel; i++) {
                        tbody.deleteRow(-1);
                }
        }
        if (nrows < num) {
                nadd = num - nrows;
                var row = document.getElementById("asearchRow"); // find row to copy
                for (var i=0; i<nadd; i++) {
                        var clone = row.cloneNode(true); // copy children too
//                        clone.id = "newID"; // change id or other attributes/contents
                        tbody.appendChild(clone); // add new row to end of table
                }
        }
}

</script>
