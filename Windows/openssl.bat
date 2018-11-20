@CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64
path=%path%;c:\dev;c:\perl64\bin

@start powershell -executionpolicy remotesigned -File openssl.ps1
