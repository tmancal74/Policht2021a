import sys
import os

import numpy

import quantarhei as qr

print("\nVerifying test calculations")
print("---------------------------")
fname = "script_Policht2021.yaml"
print("\nLoading input file:", fname)

INP=qr.Input(fname)

smode = INP.simulation_mode
print("Simulation mode:", smode)

try:
    target_dir = sys.argv[1]
except:
    print("Simulation output directory not specified")
    qr.exit()
    

print("Target dir:", target_dir)
OK = True

print("\nTest results:")

if smode == "single" or smode == "scan":
    cmpr_data = ["cont_p_re_0.qrp", "cont_p_nr_0.qrp", "cont_m_re_0.qrp", "cont_m_nr_0.qrp"]
    
    cmpr_dir = os.path.join("templates","data_test_"+smode)
    for dataf in cmpr_data:
        
        pkg_saved = qr.load_parcel(os.path.join(cmpr_dir, dataf))
        pkg_calcd = qr.load_parcel(os.path.join(target_dir, dataf))
        
        for tag in pkg_saved.spectra:
            sp_saved = pkg_saved.get_spectrum(tag)
            sp_calcd = pkg_calcd.get_spectrum(tag)
            if numpy.allclose(sp_saved.data, sp_calcd.data):
                print(dataf, ": OK")
            else:
                print(dataf, "failed: difference outside standard tolerance")
                OK = False
                
elif smode == "disorder":
    cmpr_data = ["ave_p_re.qrp", "ave_p_nr.qrp", "ave_m_re.qrp", "ave_m_nr.qrp"]
    
    cmpr_dir = os.path.join("templates","data_test_"+smode)
    for dataf in cmpr_data:
        
        pkg_saved = qr.load_parcel(os.path.join(cmpr_dir, dataf))
        pkg_calcd = qr.load_parcel(os.path.join(target_dir, dataf))
        sp_saved = pkg_saved
        sp_calcd = pkg_calcd        
        if numpy.allclose(sp_saved.data, sp_calcd.data):
            print(dataf, ": OK")
        else:
            print(dataf, "failed: difference outside standard tolerance")
            OK = False

        
if OK:
    print("\nValidation completed sucessfully!!!\n")
else:
    print("\nValidation failed!!!\n")
    

