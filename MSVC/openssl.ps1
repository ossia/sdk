# Based on https://gist.github.com/terrillmoore/995421ea6171a9aa50552f6aa4be0998

# TODO put nasm.exe in path
# TODO put perl in path
# TODO install perl Text-template

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://github.com/openssl/openssl/archive/OpenSSL_1_1_0j.zip -OutFile openssl.zip
Expand-Archive openssl.zip

cd openssl/openssl-OpenSSL_1_1_0j
perl Configure VC-WIN64A --prefix=c:\score-sdk\openssl\win64 --openssldir=c:\score-sdk\openssl\SSL no-shared
nmake
nmake install


