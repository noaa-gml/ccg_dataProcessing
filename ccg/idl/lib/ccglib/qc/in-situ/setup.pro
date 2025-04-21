PRO SETUP

CD, '/home/ccg/ken/idl/ccg/', CURRENT = cdir
RESOLVE_ROUTINE, 'ccg_plot' , /COMPILE_FULL_FILE
CD, '/home/ccg/ken/idl/qc/in-situ/'
RESOLVE_ROUTINE, 'read_insitu_raw', /COMPILE_FULL_FILE
RESOLVE_ROUTINE, 'plot_insitu_gc', /COMPILE_FULL_FILE
RESOLVE_ROUTINE, 'plot_insitu_ndir', /COMPILE_FULL_FILE
CD, cdir
END
