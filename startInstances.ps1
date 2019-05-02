$store1POS1Dir="DbData/Store1POS1"
$store1POS2Dir="DbData/Store1POS2"
$store1POS3Dir="DbData/Store1POS3"

$store2POS1Dir="DbData/Store2POS1"
$store2POS2Dir="DbData/Store2POS2"
$store2POS3Dir="DbData/Store2POS3"


if(!(Get-Item -Path $store1POS1Dir)){
    New-Item -Path $store1POS1Dir -ItemType Directory
}
if(!(Get-Item -Path $store1POS2Dir)){
    New-Item -Path $store1POS2Dir -ItemType Directory
}
if(!(Get-Item -Path $store1POS3Dir)){
    New-Item -Path $store1POS3Dir -ItemType Directory
}
if(!(Get-Item -Path $store2POS1Dir)){
    New-Item -Path $store2POS1Dir -ItemType Directory
}
if(!(Get-Item -Path $store2POS2Dir)){
    New-Item -Path $store2POS2Dir -ItemType Directory
}
if(!(Get-Item -Path $store2POS3Dir)){
    New-Item -Path $store2POS3Dir -ItemType Directory
}

# store 1 replica set 
Start-Process -FilePath "C:\Program Files\MongoDB\Server\4.0\bin\mongod.exe" -ArgumentList "--port 27050 --shardsvr --replSet store1 --dbpath $store1POS1Dir"
Start-Process -FilePath "C:\Program Files\MongoDB\Server\4.0\bin\mongod.exe" -ArgumentList "--port 27051 --shardsvr --replSet store1 --dbpath $store1POS2Dir"
Start-Process -FilePath "C:\Program Files\MongoDB\Server\4.0\bin\mongod.exe" -ArgumentList "--port 27052 --shardsvr --replSet store1 --dbpath $store1POS3Dir"
# store 2 replica set
Start-Process -FilePath "C:\Program Files\MongoDB\Server\4.0\bin\mongod.exe" -ArgumentList "--port 27053 --shardsvr --replSet store2 --dbpath $store2POS1Dir"
Start-Process -FilePath "C:\Program Files\MongoDB\Server\4.0\bin\mongod.exe" -ArgumentList "--port 27054 --shardsvr --replSet store2 --dbpath $store2POS2Dir"
Start-Process -FilePath "C:\Program Files\MongoDB\Server\4.0\bin\mongod.exe" -ArgumentList "--port 27055 --shardsvr --replSet store2 --dbpath $store2POS3Dir"

Write-Host "If this is the first launch, please connect to one of the config mongod instances and run the following commands"
Write-Host "rs.initiate( { _id: 'store1', members: [ { _id: 0, host: 'localhost:27050' }, { _id: 1, host: 'localhost:27051' }, { _id: 2, host: 'localhost:27052' } ] } )"
Write-Host "rs.initiate( { _id: 'store2', members: [ { _id: 0, host: 'localhost:27053' }, { _id: 1, host: 'localhost:27054' }, { _id: 2, host: 'localhost:27055' } ] } )"


