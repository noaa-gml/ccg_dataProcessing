        #
        # pfp_updatefiles.sh
        #
        # Move PFP history and summary file to correct location.
        #
        projdir='/projects/'
        workdir=${projdir}aircraft/
        tmpdir=${workdir}lib/pfp/tmp/

        cd ${workdir}lib/pfp/

	cd ${tmpdir}
	for histfile in `ls *.his`
	do
		year=`expr substr $histfile 1 4`
		site=`grep "Site Code" $histfile | awk '{print $3}' | tr "[A-Z]" "[a-z]"`
		sumfile=`echo $histfile | sed -e s/his/sum/`
		dest=${workdir}$site/history/$year
		if [ ! -d $dest ]
		then
			mkdir -p $dest
		fi
		mv $histfile $dest
		mv $sumfile $dest
	done
