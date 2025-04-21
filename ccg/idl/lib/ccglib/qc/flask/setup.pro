PRO SETUP

CD, '/home/ccg/ken/idl/ccg/', CURRENT = cdir
RESOLVE_ROUTINE, 'ccg_plot' , /COMPILE_FULL_FILE
CD, '/home/ccg/ken/idl/qc/flask/'
RESOLVE_ROUTINE, 'read_flask_raw', /COMPILE_FULL_FILE
RESOLVE_ROUTINE, 'plot_flask_gc', /COMPILE_FULL_FILE
CD, cdir
END
