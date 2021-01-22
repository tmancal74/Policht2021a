@echo off
rem ######################################################################
rem
rem     Configuration section
rem
rem ######################################################################

rem   set to True to start a parallel simulation, False otherwise
set PARALLEL=False

rem   set the number of precesses you want to run in parallel
set NUMBER_OF_PROCESSES=8

rem   set to True to send the output into a file instead of the screen
set SAVE_OUTPUT=False

rem   logging file name
set LOG_FILE=log

rem   set to True to run the simulation in the background, False otherwise
set BACKGROUND=True




rem ######################################################################
rem
rem     Settings (do not edit anything below this line)
rem
rem ######################################################################    
if %PARALLEL% == True (
   set PARALLELOPT= -p -n %NUMBER_OF_PROCESSES% -d mpiexec
) else (
   set PARALLELOPT=
)

if %BACKGROUND% == True (
   set STARTER=start /b
) else (
   set STARTER=
)

if %SAVE_OUTPUT% == True (
   set PIPE= ^> %LOG_FILE%
) else (
   if %BACKGROUND% == True (
      set PIPE= ^> output.log
   ) else (
      set PIPE=
   )
)

rem ######################################################################
rem
rem     Tasks
rem
rem ######################################################################

rem     Default task
if "%1" == "" (
   set task=help
) else (
   set task=%1
)

rem     Running the simulation
if %task% == run (

   if %PARALLEL% == True (
      echo Running parallel simulation on the foreground
   ) else (
      echo Running serial simulation on the foreground
   )
   if %SAVE_OUTPUT% == True (
      echo Logging output into file: %LOG_FILE%
   )
   echo Issuing command: "%STARTER% qrhei run %PARALLELOPT% script_Policht2021.yaml %PIPE%"
   if %BACKGROUND% == True (
      echo Simulation runs in backgroud. Use taskmanager to watch its progress.
   ) else (
      echo Wait untill the simulation is finished ^(use Ctrl-c to stop execution^) ...
   )   
   %STARTER% qrhei run %PARALLELOPT% script_Policht2021.yaml %PIPE%


rem     Cleaning files
) else if %task% == clean (

   echo Removing files
   for /f %%i in ('dir /a:d /b sim_*') do rmdir /s /q %%i
   del *~

) else if %task% == help (
   echo.
   echo Simulation Makefile          
   echo ===================
   echo.
   echo To configure the session, edit the switches at the start
   echo of this Makefile. You can choose between serial and parallel
   echo simulation and adjust logging and whether to run in the 
   echo background or not
   echo.
   echo Available tasks: 
   echo ---------------- 
   echo.
   echo ^> make help 
   echo.
   echo     Prints this message 
   echo.
   echo ^> make run 
   echo.
   echo     Runs the simulations. On Linux and macOS 
   echo     the job submission can be configured
   echo.
   echo ^> make clean 
   echo.
   echo     Deletes the output of the simulations 
   echo.

)
rem ##################################################################################
rem   EOF
