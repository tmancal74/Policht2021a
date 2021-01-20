all: help 

NUMBER_OF_PROCESSES=4

#PARALLEL= -p -n ${NUMBER_OF_PROCESSES}
PARALLEL=

PIPE= > log 2>&1 &
#PIPE=

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
 

clean:
	rm -rf sim* log



run: clean
	(time qrhei run ${PARALLEL} script_Policht2021.yaml) ${PIPE} 


