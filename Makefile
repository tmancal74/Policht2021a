# run simulation in parallel
PARALLEL=False

# number of processes to start
NUMBER_OF_PROCESSES=4

# run in the background
BACKGROUND=False

# save the output to a file
SAVE_OUTPUT=False

# filename to save output to (default is output.log)
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
#PIPE=

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
	@echo "> make clean "
	@echo
	@echo "    Deletes the output of the simulations "
	@echo


# delete results from all previous runs
clean:
	rm -rf sim* log output.log

del:
	rm -rf log output.log *.png *.mov *.mp4

purge: clean del


# run a simulation
run:
	(time qrhei run ${PARALLELOPT} script_Policht2021.yaml) ${PIPE}


figures:
	${PYTHON} aux_fig_single.py ${DIR}

movies:
	${PYTHON} aux_mov_scan.py ${DIR}

averages:
	${PYTHON} aux_fig_average.py ${DIR}
	
################################################################################
# EOF
