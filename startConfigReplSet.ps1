$config1Dir="DbData/Config1"
$config2Dir="DbData/Config2"
$config3Dir="DbData/Config3"

if(!(Get-Item -Path $config1Dir)){
    New-Item -Path $config1Dir -ItemType Directory
}
if(!(Get-Item -Path $config2Dir)){
    New-Item -Path $config2Dir -ItemType Directory
}
if(!(Get-Item -Path $config3Dir)){
    New-Item -Path $config3Dir -ItemType Directory
}
Start-Process -FilePath "C:\Program Files\MongoDB\Server\4.0\bin\mongod.exe" -ArgumentList "--port 27031 --configsvr --dbpath $config1Dir --replSet config"
Start-Process -FilePath "C:\Program Files\MongoDB\Server\4.0\bin\mongod.exe" -ArgumentList "--port 27032 --configsvr --dbpath $config2Dir --replSet config"
Start-Process -FilePath "C:\Program Files\MongoDB\Server\4.0\bin\mongod.exe" -ArgumentList "--port 27033 --configsvr --dbpath $config3Dir --replSet config"

Write-Host "If this is the first launch, please connect to one of the config mongod instances and run the following command"
Write-Host "rs.initiate( { _id: 'config', members: [ { _id: 0, host: 'localhost:27031' }, { _id: 1, host: 'localhost:27032' }, { _id: 2, host: 'localhost:27033' } ] } )"
