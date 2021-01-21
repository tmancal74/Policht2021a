@echo off

if "%1" == "" (
   set task=help
) else (
   set task=%1
)

if %task% == run (

   echo This is Windows and running scripts in the background here
   echo requires wizardry not know to the author of this batch file.
   echo.
   echo Running simulation on the forground
   qrhei run script_Policht2021.yaml 

) else if %task% == clean (

   echo Removing files
   for /f %%i in ('dir /a:d /b sim_*') do rmdir /s /q %%i

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

