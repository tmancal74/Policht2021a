################################################################################
#
#  GLOBAL SIMULATION SETTINGS
#  Here you can set behavior of the simulation
#  (Details of Makefile usage below the settings)
#
################################################################################

# Number of processes to start (if > 1, mpi4py Python package and MPI have
# to be installed for the simulation to run in parallel)
NUMBER_OF_PROCESSES=1

# run in the background
BACKGROUND=False

# filename to save output to (if BACKGROUND=True the default is output.log);
LOG_FILE=

# change this to your python interpreter
PYTHON= python

################################################################################
#
#  Makefile for the simulaiton scripts of the manuscript:
#
#  Veronica R. Policht, Andrew Niedringhaus, Cameron Spitzfaden,
#	 Philip D. Laible, David F. Bocian, Christine Kirmaier, Dewey Holten,
#	 Tomáš Mančal and Jennifer P. Ogilvie,
#	 Hidden Vibronic and Excitonic Structure and Vibronic Coherence Transfer
#	 in the Bacterial Reaction Center, submitted 2021
#
#  This file should work on most Linux/Unix systems (including macOS)
#
#  Type the following on the command line
#  (">" represents the command line prompt)
#
#  > make help
#
#  to see the list of available tasks. The tasks can be configured in the
#  configuration section below. Unless you know precisely what you are doing,
#  do not edit anything except the configuration section
#
################################################################################

#
#   DO NOT EDIT BELOW THIS LINE
#

SCRDIR=scr
MOVIES_SCRIP=${SCRDIR}/aux_movies.py
FIGURES_SCRIPT=${SCRDIR}/aux_figures.py
VALIDATION_SCRIPT=${SCRDIR}/validate.py

# set PARALLEL depending on the number of required processes
ifeq ($(shell test ${NUMBER_OF_PROCESSES} -gt 1; echo $$?),0)
PARALLEL=True
else
PARALLEL=False
endif

#probe MPI presence if it is required
MPI_REPORT= MPI presence not tested
ifeq (${PARALLEL},True)
ifeq ($(shell ${PYTHON} ${SCRDIR}/probe_mpi.py; echo $$?),0)
MPI_REPORT= MPI probed with success!
PARALLEL=True
else
MPI_REPORT= MPI not found \(mpi4py package or MPI implementation is missing\)
PARALLEL=False
endif
endif

# set SAVE_OUTPUT to True if a LOG_FILE is set
ifeq (${LOG_FILE},)
SAVE_OUTPUT=False
else
SAVE_OUTPUT=True
endif

PARALLELOPT=
ifeq (${PARALLEL},True)
PARALLELOPT= -p -n ${NUMBER_OF_PROCESSES}
endif

LOGGING=
ifeq (${SAVE_OUTPUT},True)
LOGGING= > ${LOG_FILE} 2>&1
endif

AMPRS=
ifeq (${BACKGROUND},True)
AMPRS=&
ifeq (${LOGGING},)
LOGGING= > output.log 2>&1
endif
endif

PIPE= ${LOGGING} ${AMPRS}

#
################################################################################
#
#   AVAILABLE TASKS
#
################################################################################
#

# default task
all: help
	@echo
	@echo Current settings:
	@echo -----------------
	@echo
	@echo NUMBER_OF_PROCESSES=${NUMBER_OF_PROCESSES}
	@echo ${MPI_REPORT}
	@echo BACKGROUND=${BACKGROUND}
	@echo LOG_FILE=${LOG_FILE}
	@echo PYTHON=${PYTHON}
	@echo
	@echo Will run in parallel: \(PARALLEL=\) ${PARALLEL}
	@echo Output will be saved: \(SAVE_OUTPUT=\) ${SAVE_OUTPUT}
	@echo

# help message
help:
	@echo
	@echo "Simulation Makefile          "
	@echo "==================="
	@echo
	@echo "To configure the session, edit the switches at the start"
	@echo "of this Makefile. You can choose between serial and parallel"
	@echo "simulation and adjust logging and whether to run in the "
	@echo "background or not "
	@echo
	@echo "Available tasks: "
	@echo "---------------- "
	@echo
	@echo "> make help "
	@echo
	@echo "    Prints this message "
	@echo
	@echo "> make run "
	@echo
	@echo "    Runs the simulations "
	@echo
	@echo "> make figures DIR=results_directory"
	@echo
	@echo "    Produces 2D omega_2 map figures from the simulation "
	@echo "    which ran in the simulation mode 'single' or 'disorder'"
	@echo "    (see configureation yaml file). results_directory is "
	@echo "    the directory containing results of Quantarhei simulation."
	@echo
	@echo "> make movies DIR=results_directory"
	@echo
	@echo "    Produces movies for the energy gap scan from the simulation "
	@echo "    which ran in the simulation mode 'scan'"
	@echo "    (see configureation yaml file). results_directory is"
	@echo "    the directory containing results of Quantarhei simulation."
	@echo
	@echo "> make clean "
	@echo
	@echo "    Deletes the output of the simulations "
	@echo
	@echo "> make del "
	@echo
	@echo "    Deletes media files created by scripts "
	@echo

# delete results from all previous runs
clean:
	rm -rf sim* log output.log *.tar *.bak random_state.qrp

# delete media produced by auxiliary scripts
del:
	rm -rf *.png *.mov *.mp4 *.log

# delete everything
purge: clean del

# run a simulation
run:
	(time qrhei run ${PARALLELOPT} script_Policht2021.yaml) ${PIPE}

# make figures from raw data (single realization or average)
figures:
	${PYTHON} ${FIGURES_SCRIPT} ${DIR}

# make movies from raw data of enegy gap scan
movies:
	${PYTHON} ${MOVIES_SCRIP} ${DIR} ${NUMBER_OF_PROCESSES}

# creates a tar ball with all the files required to run simulations (Unix/Linux/macOS only feature)
pack:
	tar cf script_policht2021.tar ${SCRDIR} make.bat Makefile
	tar rf script_policht2021.tar README.txt runme.bat script_Policht2021.*
	
back:
ifneq ("$(wildcard script_Policht2021.yaml)","")
	mv script_Policht2021.yaml script_Policht2021.yaml.bak
endif

#
# Input files for testing 
#
set_test_single: back
	cp templates/script_Policht2021_test_single.yaml ./script_Policht2021.yaml

set_test_disorder: back
	cp templates/script_Policht2021_test_disorder.yaml ./script_Policht2021.yaml
	cp templates/data_test_disorder/random_state.qrp ./
	
set_test_scan: back
	cp templates/script_Policht2021_test_scan.yaml ./script_Policht2021.yaml


test_single: set_test_single
	make run
	make validate
	make clean
	@echo test_single ended with success > test.log

test_disorder: set_test_disorder
	make run
	make validate
	make clean
	@echo test_disorder ended with success >> test.log
	
test_scan: set_test_scan
	make run 
	make validate
	make clean
	@echo test_scan enden with success >> test.log

test: purge test_single test_disorder test_scan
	
	

#
# Validation of test runs against stored data
#
validate:
	${PYTHON} ${VALIDATION_SCRIPT} ${DIR}
	
	
#
# Input files for example runs
#
set_example_single: back
	cp templates/script_Policht2021_example_single.yaml ./script_Policht2021.yaml
	
set_example_disorder: back
	cp templates/script_Policht2021_example_disorder.yaml ./script_Policht2021.yaml
	
set_example_scan: back
	cp templates/script_Policht2021_example_scan.yaml ./script_Policht2021.yaml


################################################################################
# EOF
