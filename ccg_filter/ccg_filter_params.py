# vim: tabstop=4 shiftwidth=4 expandtab
"""
A dataclass for holding parameters for ccg_filter
"""

from dataclasses import dataclass

@dataclass
class filterParameters:
    """ A dataclass for holding parameters used by ccgFilter 

    Attributes:
        npoly (int): Number of polynomial terms to use in function fit
        nharm (int): Number of harmonic terms to use in function fit
        interval (float): Sampling interval in days
        short_cutoff (int): Short term cutoff value in days
        long_cutoff (int): Long term cutoff value in days
        gapsize (float): Gap size in days to fill in with curve instead of interpolating
        zero (float): zero : Value where x=0 in function coefficients
        gain : Use amplitude gain factor if True
        fill_gap (bool) : Fill large gaps with function instead of interpolating
        gap_size (float) : Minimum gap size in days when filling gaps
        sigmaminus (float): Number of residual standard deviations below the curve
        sigmaplus (float): Number of residual standard deviations above the curve


"""

    npoly: int = 3 
    nharm: int = 4
    interval: float = 7
    short_cutoff: int = 80
    long_cutoff: int = 667
    gapsize: float = 0.0
    zero: float = -1.0
    gain: bool = False
    fill_gap: bool = False
    gap_size: float = 0
    sigmaminus: float = 3
    sigmaplus: float = 3

    def sigma_plus(self, rsd):
        """ Return the upper envelope based on residual standard deviation """

        return self.sigmaplus * rsd

    def sigma_minus(self, rsd):
        """ Return the lower envelope based on residual standard deviation """

        return self.sigmaminus * rsd * -1

