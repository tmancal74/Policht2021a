################################################################################
#
#  GLOBAL SIMULATION SETTINGS
#  Here you can set behavior of the simulation
#  (Details of Makefile usage below the settings)
#
################################################################################
# run simulation in parallel
# (mpi4py Python package and MPI have to be installed)
PARALLEL=True

# number of processes to start (has no effect if PARALLEL=False)
NUMBER_OF_PROCESSES=1

# run in the background
BACKGROUND=False

# save the output to a file
SAVE_OUTPUT=False

# filename to save output to (default is output.log);
# has no effect if SAVE_OUTPUT=False
LOG_FILE=log

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

ifeq (${LOG_FILE},)
LOG_FILE=output.log
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
LOGGING= > ${LOG_FILE} 2>&1
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
	@echo "    Produces 2D omega_2 map figures from simulation results "
	@echo "    stored in the results_directory "
	@echo
	@echo "> make movies DIR=results_directory"
	@echo
	@echo "    Produces movies for the energy gap scan from simulation results "
	@echo "    stored in the results_directory "
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
	rm -rf sim* log output.log

# delete media produced by auxiliary scripts
del:
	rm -rf *.png *.mov *.mp4

# delete everything
purge: clean del

# run a simulation
run:
	(time qrhei run ${PARALLELOPT} script_Policht2021.yaml) ${PIPE}

# make figures from raw data (single realization or average)
figures:
	${PYTHON} aux_figures.py ${DIR}

# make movies from raw data of enegy gap scan
movies:
	${PYTHON} aux_movies.py ${DIR} ${NUMBER_OF_PROCESSES}

################################################################################
# EOF
