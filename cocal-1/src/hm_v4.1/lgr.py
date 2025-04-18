    #########################################################################
    def lgr_test(sysname):
        """ Simulate an lgr output string """

        import random


    #ch4, j, h2o, j, co2, j, cell_pressure, j, cell_temp, j, j, j, ring_down, j, ring_down, j, j

    # co, j, n2o, j, h2o, j, co_dry, j, n2o_dry, j, press, j, temp, j, j, j, j, j, j

        dt = datetime.datetime.now()

    #    s = "%4d %d %d %d %d %d" % (dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)

        if "CH4" in sysname:
            ch4 = 1.920 + random.gauss(0, 0.015)
            co2 = 410 + random.gauss(0, 0.8)
            cell_temp = 45 + random.gauss(0, 0.03)
            cell_press = 140 + random.gauss(0, 0.2)

    #s = "    02/06/13 15:15:36.889,    1.93523e+00,    0.00000e+00,    1.67759e+02,    0.00000e+00,    4.28262e+02,    0.00000e+00,    1.39713e+02,    0.00000e+00,    4.51228e+01,    0.00000e+00,    5.90411e+00,    0.00000e+00,    1.08492e+01,    0.00000e+00,    7.97098e+00,    0.00000e+00,              3"

            data = "    %02d/%02d/%02d %02d:%02d:%06.3f,    %11.5e,    0.00000e+00,    1.67759e+02,    0.00000e+00,    %11.5e,    0.00000e+00,    %11.5e,    0.00000e+00,    %11.5e,    0.00000e+00,    5.90411e+00,    0.00000e+00,    1.08492e+01,    0.00000e+00,    7.97098e+00,    0.00000e+00,              3" % (dt.month, dt.day, dt.year-2000, dt.hour, dt.minute, dt.second + dt.microsecond/1000000, ch4, co2, cell_press, cell_temp)


        else:
            n2o = 338 + random.gauss(0, 0.2)
            co = 125 + random.gauss(0, 0.8)
            cell_temp = 39 + random.gauss(0, 0.1)
            cell_press = 85 + random.gauss(0, 0.2)

            data = "    %02d/%02d/%02d %02d:%02d:%06.3f,    %11.5e,    0.00000e+00,    %11.5e,    0.00000e+00,      1.67759e+02,    0.00000e+00,    0.00000e+00,    0.00000e+00,    0.00000e+00,    0.00000e+00,    %11.5e,    0.00000e+00,    %11.5e,    0.00000e+00,    1.08492e+01,    0.00000e+00,    7.97098e+00,    0.00000e+00,              3" % (dt.month, dt.day, dt.year-2000, dt.hour, dt.minute, dt.second + dt.microsecond/1000000, co, n2o, cell_press, cell_temp)


        return data
