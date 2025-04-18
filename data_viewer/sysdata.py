# vim: tabstop=4 shiftwidth=4 expandtab
"""
routines used for plotting data in dataWindows for fledit, caledit ...
"""

import ccg_nl
import ccg_peaktype


# ----------------------------------------------------------------
def plot_mole_fractions(df, plot):
    """ plot mole fractions of flasks versus analysis date and time """

    df2 = df[df.smptype == 'SMP']
    if df2.flag.isnull().any():
        return

    # unflagged
    df3 = df2.loc[df2.flag.str.match(r"\.\..")]
    x = df3.date.tolist()
    y = df3.mole_fraction.tolist()
    plot.createDataset(x, y, name="SMP unflagged", color="blue")

    # soft flags
    df3 = df2.loc[df2.flag.str.match(r"\.[^\.].")]
    x = df3.date.tolist()
    y = df3.mole_fraction.tolist()
    plot.createDataset(x, y, name="SMP soft flags", color="#0c0")

    # hard flags
    df3 = df2.loc[df2.flag.str.match(r"[^\.]..")]
    x = df3.date.tolist()
    y = df3.mole_fraction.tolist()
    plot.createDataset(x, y, name="SMP hard flags", color="red")


# ------------------------------------------------------------------------
def response_curve(files, plot):
    """ plot response curve and input data for the curve """

    for n, rawfile in enumerate(files):

        nldata = ccg_nl.Response(rawfile)

        # find max input value along x axis
        xi = []
        yi = []
        for key, (xp, xpsd, yp, ypsd, num) in nldata.avg.items():
            xi.append(xp)
            yi.append(yp)

        x, y = nldata.get_values(min(xi), max(xi))

        plot.createDataset(x, y,
                           "Response %s" % nldata.adate.strftime("%Y-%m-%d"),
                           symbol='none',
                           linecolor=plot.colors[n % 11])

        plot.createDataset(xi, yi,
                           "Input data %s" % nldata.adate.strftime("%Y-%m-%d"),
                           symbol='circle',
                           color=plot.colors[n % 11],
                           markersize=5,
                           connector="None")


# ----------------------------------------------------------------
def residuals(files, plot):
    """ plot residuals from the response curve """

    for n, rawfile in enumerate(files):

        nldata = ccg_nl.Response(rawfile)
        x, y = nldata.getResiduals()

        plot.createDataset(x, y,
                           "Residuals %s" % nldata.adate.strftime("%Y-%m-%d"),
                           symbol='circle',
                           color=plot.colors[n % 11],
                           markersize=5,
                           connector="None")


# ----------------------------------------------------------------
def reference(data, df, title, plot):
    """ Plot only the reference gas analyzer values """

    xp = {}
    yp = {}
    xpf = {}
    ypf = {}

    print(data)
    label = "REF"
    param = "value"
    if data.method == "GC":
        peaktype = ccg_peaktype.getPeaktype(data.inst, data.parameter)
        if peaktype == "height":
            param = "ph"
        else:
            param = "pa"

    # unflagged
    df2 = df[(df.smptype == label) & (df.rawflag == '.') & (df[param].notna())]
    xvals = df2.date
    yvals = df2[param]
    xp[label] = xvals.tolist()
    yp[label] = yvals.tolist()

    # flagged
    df2 = df[(df.smptype == label) & (df.rawflag != '.')]
    xvals = df2.date
    yvals = df2[param]
    xpf[label] = xvals.tolist()
    ypf[label] = yvals.tolist()

    for n, label in enumerate(xp):
        if 'None' in yp[label]:
            continue
        plot.createDataset(xp[label], yp[label], name=label, color=plot.colors[n % 11], symbol='square')
        if len(xpf[label]) > 0:
            plot.createDataset(xpf[label], ypf[label],
                               name=label + " flagged",
                               outlinecolor=plot.colors[n % 11],
                               outlinewidth=2,
                               markersize=3,
                               symbol='+',
                               linetype='None')


# ----------------------------------------------------------------
def plot_raw_signal(df, param, title, plot, separate=True):
    """ plot a data column from the dataframe vs analysis date """

    xp = {}
    yp = {}
    xpf = {}
    ypf = {}

    if separate:

        labels = df[df.smptype != 'SMP'].event.unique().tolist()
        labels.append("SMP")

        # get data for standards and reference gases
        for label in labels:

            # unflagged
            if label == "SMP":
                df2 = df[(df.smptype == label) & (df.rawflag == '.') & (df[param].notna())]
            else:
                df2 = df[(df.event == label) & (df.rawflag == '.') & (df[param].notna())]
            xvals = df2.date
            yvals = df2[param]
            xp[label] = xvals.tolist()
            yp[label] = yvals.tolist()

            # flagged
            if label == "SMP":
                df2 = df[(df.smptype == label) & (df.rawflag != '.')]
            else:
                df2 = df[(df.event == label) & (df.rawflag != '.')]
            xvals = df2.date
            yvals = df2[param]
            xpf[label] = xvals.tolist()
            ypf[label] = yvals.tolist()

        for n, label in enumerate(xp):
            if 'None' in yp[label]:
                continue
            plot.createDataset(xp[label], yp[label], name=label, color=plot.colors[n % 11], symbol='square')
            if len(xpf[label]) > 0:
                plot.createDataset(xpf[label], ypf[label],
                                   name=label + " flagged",
                                   outlinecolor=plot.colors[n % 11],
                                   outlinewidth=2,
                                   markersize=3,
                                   symbol='+',
                                   linetype='None')

    else:

        df2 = df[df.rawflag == '.']
        xvals = df2.date.tolist()
        yvals = df2[param].tolist()
        label = title
        plot.createDataset(xvals, yvals, name=label, color=plot.colors[0 % 11], symbol='square')

        df2 = df[df.rawflag != '.']
        xvals = df2.date.tolist()
        yvals = df2[param].tolist()
        label = title + " flagged"
        plot.createDataset(xvals, yvals, name=label, color=plot.colors[0 % 11], symbol='square')
