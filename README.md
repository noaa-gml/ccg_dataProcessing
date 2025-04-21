# ccg_dataProcessing
Processing, hardware management, system control and quality control software for CCGG flask, insitu and calibration data.

## Directory Overview

- `/db_ddl`:  
  Contains creation files for various MariaDB tables, views, functions and stored procedures in the primary data repository.

- `/instrument_systems`:  
  Contains software for controlling and running flask and calibration measurement systems.

- `/web_applications`:  
  Contains PHP web applications used for QC, operations, and logistics.

- `/ccg`:  
  The primary directory tree for the following projects:

  
Flask Processing
================

/ccg/src/python3/nextgen/ccg_flag.py
/ccg/src/python3/nextgen/ccg_flask2.py
/ccg/src/python3/nextgen/ccg_flask_corr.py
/ccg/src/python3/nextgen/ccg_flask_data.py
/ccg/src/python3/nextgen/ccg_flaskdb2.py
/ccg/src/python3/nextgen/ccg_flaskdb.py
/ccg/src/python3/nextgen/ccg_flask.py
/ccg/src/python3/nextgen/flflag.py
/ccg/src/python3/nextgen/flpro2.py
/ccg/src/python3/nextgen/flpro.py

Calbration Processing
================

/ccg/src/python3/nextgen/cal_co2isotopes.py
/ccg/src/python3/nextgen/calpro.py
/ccg/src/python3/nextgen/ccg_cal.py
/ccg/src/python3/nextgen/ccg_dilution.py
/ccg/src/python3/nextgen/ccg_nl.py
/ccg/src/python3/nextgen/ccg_response_file.py
/ccg/src/python3/nextgen/ccg_response.py
/ccg/src/python3/nextgen/nlpro.py
/ccg/src/python3/nextgen/pic_h2o_corr.py
/ccg/src/python3/nextgen/pic_resp.py
/ccg/src/python3/nextgen/read_water_coefs.py
/ccg/src/python3/caldrift.py
/ccg/src/python3/reftank.py

Insitu Processing
================

/ccg/src/python3/nextgen/acmie.py
/ccg/src/python3/nextgen/amie.py
/ccg/src/python3/nextgen/ccg_average_obs.py
/ccg/src/python3/nextgen/ccg_average.py
/ccg/src/python3/nextgen/ccg_average_tower.py
/ccg/src/python3/nextgen/ccg_insitu_config.py
/ccg/src/python3/nextgen/ccg_insitu_corr.py
/ccg/src/python3/nextgen/ccg_insitu_data_1table.py
/ccg/src/python3/nextgen/ccg_insitu_data2.py
/ccg/src/python3/nextgen/ccg_insitu_data.py
/ccg/src/python3/nextgen/ccg_insitu_db.py
/ccg/src/python3/nextgen/ccg_insitu_db_test.py
/ccg/src/python3/nextgen/ccg_insitu_files.py
/ccg/src/python3/nextgen/ccg_insitu_flag.py
/ccg/src/python3/nextgen/ccg_insitu_gc_co.py
/ccg/src/python3/nextgen/ccg_insitu_gc.py
/ccg/src/python3/nextgen/ccg_insitu_intake.py
/ccg/src/python3/nextgen/ccg_insitu_labcal.py
/ccg/src/python3/nextgen/ccg_insitu_lbl.py
/ccg/src/python3/nextgen/ccg_insitu_ndir.py
/ccg/src/python3/nextgen/ccg_insitu.py
/ccg/src/python3/nextgen/ccg_insitu_qc.py
/ccg/src/python3/nextgen/ccg_insitu_qc_rules.py
/ccg/src/python3/nextgen/ccg_insitu_raw.py
/ccg/src/python3/nextgen/ccg_insitu_response_odr.py
/ccg/src/python3/nextgen/ccg_insitu_response.py
/ccg/src/python3/nextgen/ccg_insitu_stats.py
/ccg/src/python3/nextgen/ccg_insitu_systems.py
/ccg/src/python3/nextgen/ccg_insitu_tower_odr.py
/ccg/src/python3/nextgen/ccg_insitu_utils.py
/ccg/src/python3/nextgen/ccg_insitu_wgc.py
/ccg/src/python3/nextgen/ccgis.py
/ccg/src/python3/nextgen/flag_insitu.py
/ccg/src/python3/nextgen/makeavg.py
/ccg/src/python3/nextgen/makeraw_insitu_pd_mko.py
/ccg/src/python3/nextgen/makeraw_insitu_pd.py
/ccg/src/python3/nextgen/makeraw_insitu_pd_tower.py
/ccg/src/python3/nextgen/makeraw_insitu_pd_wgc.py
/ccg/src/python3/nextgen/makeraw_insitu.py
/ccg/src/python3/nextgen/mk_resp_raw.py
/ccg/src/python3/nextgen/tower_make_data_pd.py
/ccg/src/python3/nextgen/tower_make_data.py
/ccg/src/python3/nextgen/tower_make_qc.py
/ccg/src/python3/nextgen/tower_read_rawdata.py
/ccg/src/python3/nextgen/update_refgas.py
/ccg/src/python3/co2select.py
/ccg/src/python3/ch4select.py


CCG Filter
================
/ccg/python/ccglib/ccgcrv.py
/ccg/python/ccglib/ccg_filter_export.py
/ccg/python/ccglib/ccg_filter_params.py
/ccg/python/ccglib/ccg_filter.py
/ccg/python/ccglib/ccg_quickfilter.py


General
================

/ccg/src/python3/nextgen/ccg_peaktype.py
/ccg/src/python3/nextgen/ccg_process.py
/ccg/src/python3/nextgen/ccg_rawdf.py
/ccg/src/python3/nextgen/ccg_rawfile.py

/ccg/python/ccglib/ccg_aircraft_insitu_data.py
/ccg/python/ccglib/ccg_bldsql.py
/ccg/python/ccglib/ccg_cal_db.py
/ccg/python/ccglib/ccg_calfit.py
/ccg/python/ccglib/ccg_calunc.py
/ccg/python/ccglib/ccg_csv_utils.py
/ccg/python/ccglib/ccg_dates.py
/ccg/python/ccglib/ccg_date_utils.py
/ccg/python/ccglib/ccg_db_conn.py
/ccg/python/ccglib/ccg_dbutils.py
/ccg/python/ccglib/ccg_elevation.py
/ccg/python/ccglib/ccg_fic.py
/ccg/python/ccglib/ccg_file_utils.py
/ccg/python/ccglib/ccg_flask_data.py
/ccg/python/ccglib/ccg_grav_refgasdb.py
/ccg/python/ccglib/ccg_insitu_data2.py
/ccg/python/ccglib/ccg_insitu_intake.py
/ccg/python/ccglib/ccg_instrument.py
/ccg/python/ccglib/ccg_ncdf.py
/ccg/python/ccglib/ccg_refgasdb.py
/ccg/python/ccglib/ccg_tankhistory.py
/ccg/python/ccglib/ccg_tower_data.py
/ccg/python/ccglib/ccg_uncdata_all.py
/ccg/python/ccglib/ccg_utils.py


Hardware Manager
=====================
/ccg/src/hm/python/v4.2/action.py
/ccg/src/hm/python/v4.2/aerodyne.py
/ccg/src/hm/python/v4.2/daq.py
/ccg/src/hm/python/v4.2/device.py
/ccg/src/hm/python/v4.2/errornum.py
/ccg/src/hm/python/v4.2/find_device.py
/ccg/src/hm/python/v4.2/hm.py
/ccg/src/hm/python/v4.2/hmsubs.py
/ccg/src/hm/python/v4.2/hp35900.py
/ccg/src/hm/python/v4.2/lgr.py
/ccg/src/hm/python/v4.2/lock_file.py
/ccg/src/hm/python/v4.2/picarro.py
/ccg/src/hm/python/v4.2/pp.py
/ccg/src/hm/python/v4.2/runaction.py
/ccg/src/hm/python/v4.2/scpi.py
/ccg/src/hm/python/v4.2/test.py
/ccg/src/hm/python/v4.2/valco.py
/ccg/src/hm/python/v4.2/vurf.py

Nextgen Insitu System Control
=====================
/ccg/src/nextgen/dist/nextgen-2024-11-21.tar.gz
/ccg/src/nextgen/dist/nextgen_update-2025-01-30.tar.gz
/ccg/src/nextgen/dist/nextgen-doc-2024-04-18.tar.gz
/ccg/src/nextgen/dist/webserver-2024-03-21.tar.gz
/ccg/src/nextgen/dist/web_setup.sh

Data Viewer (QC)
========================
/ccg/src/dv/v8.0/traj/traj.py
/ccg/src/dv/v8.0/traj/images.py
/ccg/src/dv/v8.0/traj/extchoice.py
/ccg/src/dv/v8.0/caledit/calib.py
/ccg/src/dv/v8.0/caledit/dataWindow.py
/ccg/src/dv/v8.0/flsel/getncdf.py
/ccg/src/dv/v8.0/flsel/flsel.py
/ccg/src/dv/v8.0/gcplot.py
/ccg/src/dv/v8.0/dv.py
/ccg/src/dv/v8.0/dei/latgrad.py
/ccg/src/dv/v8.0/dei/template.py
/ccg/src/dv/v8.0/dei/help.py
/ccg/src/dv/v8.0/dei/bs_mbl.py
/ccg/src/dv/v8.0/dei/mbl.py
/ccg/src/dv/v8.0/dei/setloc.py
/ccg/src/dv/v8.0/dei/dei.py
/ccg/src/dv/v8.0/isedit.py
/ccg/src/dv/v8.0/reftab/scale.py
/ccg/src/dv/v8.0/isedit/insitu.py
/ccg/src/dv/v8.0/isedit/tanks.py
/ccg/src/dv/v8.0/isedit/sysdata.py
/ccg/src/dv/v8.0/isedit/dataWindow.py
/ccg/src/dv/v8.0/isedit/open.py
/ccg/src/dv/v8.0/isedit/flag.py
/ccg/src/dv/v8.0/gcplot/data.py
/ccg/src/dv/v8.0/gcplot/main.py
/ccg/src/dv/v8.0/gcplot/open.py
/ccg/src/dv/v8.0/gcplot/setfiles.py
/ccg/src/dv/v8.0/common/getraw.py
/ccg/src/dv/v8.0/common/ImageView.py
/ccg/src/dv/v8.0/common/edit_dialog.py
/ccg/src/dv/v8.0/common/params.py
/ccg/src/dv/v8.0/common/flask_listbox.py
/ccg/src/dv/v8.0/common/find_raw_file.py
/ccg/src/dv/v8.0/common/hist.py
/ccg/src/dv/v8.0/common/FileView.py
/ccg/src/dv/v8.0/common/importdata.py
/ccg/src/dv/v8.0/common/getimportdata.py
/ccg/src/dv/v8.0/common/sysdata.py
/ccg/src/dv/v8.0/common/getdata.py
/ccg/src/dv/v8.0/common/TextView.py
/ccg/src/dv/v8.0/common/utils.py
/ccg/src/dv/v8.0/common/get.py
/ccg/src/dv/v8.0/common/validators.py
/ccg/src/dv/v8.0/common/regres.py
/ccg/src/dv/v8.0/common/getrange.py
/ccg/src/dv/v8.0/common/combolist.py
/ccg/src/dv/v8.0/common/extchoice.py
/ccg/src/dv/v8.0/common/bak/get.old.py
/ccg/src/dv/v8.0/common/bak/flget.py
/ccg/src/dv/v8.0/common/bak/getinsitu.py
/ccg/src/dv/v8.0/common/stats.py
/ccg/src/dv/v8.0/nledit/params.py
/ccg/src/dv/v8.0/nledit/nlclass.py
/ccg/src/dv/v8.0/nledit/recalc.py
/ccg/src/dv/v8.0/nledit/viewdata.py
/ccg/src/dv/v8.0/nledit/dataWindow.py
/ccg/src/dv/v8.0/nledit/openfile.py
/ccg/src/dv/v8.0/fledit.py
/ccg/src/dv/v8.0/bin/surface_subset.py
/ccg/src/dv/v8.0/fl/fl.py
/ccg/src/dv/v8.0/fl/flview.py
/ccg/src/dv/v8.0/fl/flpressure.py
/ccg/src/dv/v8.0/ccgvu/filter_data.py
/ccg/src/dv/v8.0/ccgvu/ccgvu.standalone.py
/ccg/src/dv/v8.0/ccgvu/export.py
/ccg/src/dv/v8.0/ccgvu/help.py
/ccg/src/dv/v8.0/ccgvu/ccgvu.py
/ccg/src/dv/v8.0/met/metdata.py
/ccg/src/dv/v8.0/met/met.py
/ccg/src/dv/v8.0/met/dataWindow.py
/ccg/src/dv/v8.0/met/open.py
/ccg/src/dv/v8.0/cal/cal.py
/ccg/src/dv/v8.0/vp/vp.py
/ccg/src/dv/v8.0/vp/get.py
/ccg/src/dv/v8.0/fledit/dataWindow.py
/ccg/src/dv/v8.0/fledit/flask.py
/ccg/src/dv/v8.0/fledit/tst2.py
/ccg/src/dv/v8.0/fledit/tst.py
/ccg/src/dv/v8.0/dei.py
/ccg/src/dv/v8.0/graph5/font.py
/ccg/src/dv/v8.0/graph5/editaxis.py
/ccg/src/dv/v8.0/graph5/datenum.py
/ccg/src/dv/v8.0/graph5/toolbars.py
/ccg/src/dv/v8.0/graph5/graph.py
/ccg/src/dv/v8.0/graph5/dataset.py
/ccg/src/dv/v8.0/graph5/test/tstchart.py
/ccg/src/dv/v8.0/graph5/test/tst1.py
/ccg/src/dv/v8.0/graph5/test/tst5.py
/ccg/src/dv/v8.0/graph5/test/tst4.py
/ccg/src/dv/v8.0/graph5/test/tst6.py
/ccg/src/dv/v8.0/graph5/test/tsttwo.py
/ccg/src/dv/v8.0/graph5/test/tst8.py
/ccg/src/dv/v8.0/graph5/test/tst7.py
/ccg/src/dv/v8.0/graph5/test/tst2.py
/ccg/src/dv/v8.0/graph5/test/tst9.py
/ccg/src/dv/v8.0/graph5/test/tstpickle.py
/ccg/src/dv/v8.0/graph5/test/tst3.py
/ccg/src/dv/v8.0/graph5/test/tst.py
/ccg/src/dv/v8.0/graph5/test/tstband.py
/ccg/src/dv/v8.0/graph5/text.py
/ccg/src/dv/v8.0/graph5/title.py
/ccg/src/dv/v8.0/graph5/doc/conf.py
/ccg/src/dv/v8.0/graph5/graph_menu.py
/ccg/src/dv/v8.0/graph5/crosshair.py
/ccg/src/dv/v8.0/graph5/axis.py
/ccg/src/dv/v8.0/graph5/examples/simple_plot.py
/ccg/src/dv/v8.0/graph5/examples/stripchart.py
/ccg/src/dv/v8.0/graph5/examples/__init__.py
/ccg/src/dv/v8.0/graph5/prefs.py
/ccg/src/dv/v8.0/graph5/legend.py
/ccg/src/dv/v8.0/graph5/linetypes.py
/ccg/src/dv/v8.0/graph5/style.py
/ccg/src/dv/v8.0/graph5/pen.py
/ccg/src/dv/v8.0/graph5/printout.py
/ccg/src/dv/v8.0/grapher/grapher.py
/ccg/src/dv/v8.0/grapher/target.py
/ccg/src/dv/v8.0/grapher/mbl.py
/ccg/src/dv/v8.0/grapher/met.py
/ccg/src/dv/v8.0/grapher/fic.py
/ccg/src/dv/v8.0/grapher/save.py
/ccg/src/dv/v8.0/grapher/getinsitu.py
/ccg/src/dv/v8.0/caledit.py
/ccg/src/dv/v8.0/reftab.py
/ccg/src/dv/v8.0/nledit.py
/ccg/src/dv/current/bitmaps/

Peak Integration
=========================
/ccg/src/integrator/x86_64/gc_timefile.c
/ccg/src/integrator/x86_64/gc_utils.c
/ccg/src/integrator/x86_64/gc_detrend.c
/ccg/src/integrator/x86_64/programs/gccvt.c
/ccg/src/integrator/x86_64/programs/gcdata.c
/ccg/src/integrator/x86_64/programs/gcmerge.c
/ccg/src/integrator/x86_64/programs/gcprint.c
/ccg/src/integrator/x86_64/programs/gcinfo.c
/ccg/src/integrator/x86_64/programs/gcconvert.c
/ccg/src/integrator/x86_64/programs/gcpeak.c
/ccg/src/integrator/x86_64/programs/readgc.c
/ccg/src/integrator/x86_64/gc_baselinefit.c
/ccg/src/integrator/x86_64/gc.c
/ccg/src/integrator/x86_64/gc_smooth.c
/ccg/src/integrator/x86_64/gc_integrate.c
/ccg/src/integrator/x86_64/gc_area.c
/ccg/src/integrator/x86_64/gc_segments.c
/ccg/src/integrator/x86_64/gc_convert.c
/ccg/src/integrator/x86_64/gc_resolve.c
/ccg/src/integrator/x86_64/gc_id.c
/ccg/src/integrator/x86_64/gc_find.c
