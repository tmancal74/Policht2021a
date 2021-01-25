@echo off
rem #######################################################################
rem
rem     This script models the behaviour of the Unix/Linux utility
rem     called make. You do not need to install make on your Windows
rem     system to run the simulations in this directory.
rem
rem     This file uses "Makefile" as its configuration file. If you want to
rem     change the behaviour of this script, edit the opening few lines
rem     of Makefile. Makefile resides in the same directory as this script.
rem
rem #######################################################################

for /f "tokens=1,2 delims==" %%a in (Makefile) do (
if %%a==PARALLEL set PARALLEL=%%b
if %%a==NUMBER_OF_PROCESSES set NUMBER_OF_PROCESSES=%%b
if %%a==SAVE_OUTPUT set SAVE_OUTPUT=%%b
if %%a==LOG_FILE set LOG_FILE=%%b
if %%a==BACKGROUND set BACKGROUND=%%b
if %%a==PYTHON set PYTHON=%%b
)

rem ######################################################################
rem
rem     Settings (do not edit anything below this line)
rem
rem ######################################################################

set MOVIES_SCRIP=auxscr\aux_movies.py
set FIGURES_SCRIPT=auxscr\aux_figures.py

if %PARALLEL% == True (
   set PARALLELOPT= -p -n %NUMBER_OF_PROCESSES% -d mpiexec
) else (
   set PARALLELOPT=
)

if %PARALLEL% == False (
   set NUMBER_OF_PROCESSES=1
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


) else if %task% == figures (

   %PYTHON% %FIGURES_SCRIPT% %2

) else if %task% == movies (

   %PYTHON% %MOVIES_SCRIP% %2 %NUMBER_OF_PROCESSES%

rem     Cleaning files
) else if %task% == clean (

   echo Removing files
   for /f %%i in ('dir /a:d /b sim_*') do rmdir /s /q %%i
   if exist *~ del *~
   if exist log del log
   if exist output.log del output.log

rem     Cleaning media files
) else if %task% == del (

   echo Removing files
   if exist *.png del *.png
   if exist *.mov del *.mov
   if exist *.mp4 del *.mp4

rem    Help message
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
   echo ^> make figures results_directory
   echo.
   echo     Produces 2D omega_2 map figures. results_directory is
   echo     the directory containing results of Quantarhei simulation.
   echo.
   echo ^> make movies results_directory
   echo.
   echo     Produces movies for the energy gap scan. results_directory is
   echo     the directory containing results of Quantarhei simulation.
   echo.
   echo ^> make clean
   echo.
   echo     Deletes the output of the simulations
   echo.
   echo ^> make del
   echo.
   echo     Deletes media files created by scripts
   echo.
)
rem ##################################################################################
rem   EOF
