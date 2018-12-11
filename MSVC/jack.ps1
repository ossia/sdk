[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
git clone https://github.com/jackaudio/jack2

New-Item -ItemType Directory -Force -Path C:\score-sdk\jack\include
Copy-Item jack2/common/jack -Destination C:\score-sdk\jack\include\ -Recurse -Force

