@echo off
rem ######################################################################
rem
rem     Configuration section
rem     
rem     This file uses Makefile as its configuration file. If you want to
rem     change the behaviour of this script, edit the opening few lines
rem     of Makefile.
rem
rem     Makefile resides in the same directory as this script
rem
rem ######################################################################

for /f "tokens=1,2 delims==" %%a in (Makefile) do (
if %%a==PARALLEL set PARALLEL=%%b
if %%a==NUMBER_OF_PROCESSES set NUMBER_OF_PROCESSES=%%b
if %%a==SAVE_OUTPUT set SAVE_OUTPUT=%%b
if %%a==LOG_FILE set LOG_FILE=%%b
if %%a==BACKGROUND set BACKGROUND=%%b
)

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
      echo Running parallel simulation
   ) else (
      echo Running serial simulation
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
   if exist *~ del *~
   if exist log del log
   if exist output.log del output.log

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
