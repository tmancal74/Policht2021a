#! /home/tomas/anaconda3/bin/python

import os
import numpy
import scipy.io as io
import matplotlib as mpl
import sys

import quantarhei as qr

###############################################################################
#
#  ADVANCED CONFIGURATION SECTION
#
###############################################################################

# Number of contours
Ncont = 10

# 2D spectrum range in 1/cm
window=[10500,13550,10500,13550]

#cmpfile = None
cmpfile = "parula_colormap.mat"

###############################################################################
#
#  END OF CONFIGURATION SECTION
#
###############################################################################

try:
    dname = sys.argv[1]
except:
    print("Simulation output directory not specified")
    qr.exit()

show_plot = True

combinations = [["p", "re"], ["p", "nr"], ["m", "re"], ["m", "nr"]]

clrmp = io.loadmat(cmpfile)["colmap"]
cmap = mpl.colors.ListedColormap(clrmp)

for comb in combinations:
    fsign = comb[0]
    tsigl = comb[1]

    fname = "ave_"+fsign+"_"+tsigl+".qrp"

    floc = os.path.join(dname,fname)

    av = qr.load_parcel(floc)

    print("loaded")
    mx = numpy.max(numpy.abs(av.data))
    av.data = av.data/mx


    try:
        with qr.energy_units("1/cm"):
            av.plot(spart=qr.part_ABS, Npos_contours=Ncont, window=window,
            cmap=cmap, vmin_ratio=0.0)
            av.savefig("fig_"+fsign+"_"+tsigl+"_cont="+str(Ncont)+".png")
        if show_plot:
            qr.show_plot()
    except:
        raise Exception()
