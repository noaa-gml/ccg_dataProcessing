def mad_filter(vals, limit):
    #selected_vals = []
    test_vals = []
    new_flags = []
    abs_diff = []

    median = np.median(vals)
    # get median absolute deviation. 
    # 1.4826 constant scaling used when assuming normally distributed data
    #        Note: in python3 can use: mad=stats.median_abs_deviation(vals, scale="normal") 
    #              include 'from scipy import stats' in header of file. 
    #mad = np.median(abs(vals-median)) * 1.4826 # for python2
    mad = stats.median_abs_deviation(vals, scale="normal")

    for n, x in enumerate(vals):
        a_diff = abs(x-median)
        t_val = a_diff/mad

        if (abs(x - median) / mad) <= limit:
            new_flags.append('.')
            #selected_molefraction.append(mole_fraction[n])
        else:
            new_flags.append('F')

        test_vals.append(t_val)
        abs_diff.append(a_diff)

    return median, mad, abs_diff, test_vals, new_flags

