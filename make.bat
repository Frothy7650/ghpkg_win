@echo off
REM Create build directory if it doesn't exist
if not exist build (
    mkdir build
)

REM Change into src directory
cd src

REM Compile with V for Windows
v -os windows -cc gcc . -o ghpkg.exe

REM Move compiled binary to build folder
move /Y ghpkg.exe ..\build\ghpkg.exe

REM Return to root directory
cd ..
echo Build complete: build\ghpkg.exe
