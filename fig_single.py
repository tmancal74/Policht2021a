#
#  This script produces figures from the raw Quantarhei data output
#
#
#
#  HOW RUN THIS SCRIPT
#  -------------------
#
#  Use the Makefile in the same directory as this script. If you type
#
#  > make figures DIR=results_dir
#
#  where results_dir is the name of the output directory of Quantarhei
#  simulation, this script will be run by the Python interpreter and figures
#  will be produced.
#
#  You can also supply a color map as a *.mat file (produced by Matlab) as
#  a second argument as below:
#
#  > make figures DIR=results_dir CMAP=colormap_file
#
#

import scipy.io as io
import matplotlib as mpl
import numpy
import sys, os

import quantarhei as qr

print()
print("===============================")
print("      Creating figures")
print("===============================")

try:
    target_dir = sys.argv[1]
except:
    print("Simulation output directory not specified")
    qr.exit()

ext = {0:"p_re", 1:"p_nr", 2:"m_re", 3:"m_nr"}
fig = None
Ncont = 10

nodes = [0] #, 1, 2]

# use submitted matlab colormap
try:
    cmlfile = sys.argv[2]
except:
    cmlfile = None
if cmlfile is not None:
    clrmp = io.loadmat(cmlfile)["colmap"]
    cmap = mpl.colors.ListedColormap(clrmp)
else:
    cmap = None

for ext_i in range(4):

    print("\nSignal component:", ext[ext_i])

    cont = qr.TwoDSpectrumContainer()
    cont.use_indexing_type("integer")

    do_nodes = True
    ii = 0
    for node in nodes:

        if do_nodes:
            ndp = "_"+str(node)
        else:
            ndp = ""

        file_name = os.path.join(target_dir, "cont_"+ext[ext_i]+ndp+".qrp")
        print("Loading file:", file_name)
        conta = qr.load_parcel(file_name)

        for tag in conta.spectra:
            print("(node, tag, new tag):", node, tag, ii)
            sp = conta.get_spectrum(tag)
            ntag = ii
            cont.set_spectrum(sp, tag=ntag)
            ii += 1

    print("Summary ("+ext[ext_i]+"):")
    for tag in cont.spectra:

        sp = cont.get_spectrum(tag)
        print(tag, sp.params["dE"])
        sp.normalize2(dpart=qr.part_ABS)
        with qr.energy_units("1/cm"):
            if fig is None:
                fig = sp.plot(spart=qr.part_ABS, Npos_contours=Ncont, window=[10500,13550,10500,13550], cmap=cmap, vmin_ratio=0.0)
            else:
                fig  = sp.plot(fig=fig)

        file_name = "sp_"+str(tag)+"_"+ext[ext_i]+".png"
        print("Saving file:", file_name)
        sp.savefig(file_name)

print("\n       ... finished")
print("===============================")
#cont.make_movie("mov.mp4")
