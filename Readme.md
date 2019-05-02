# MongoDB - Sharding + Zones

## Start Configuration ReplicaSet

1. Run the following Powershell script

```Powershell
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

```

2. Then connect to one of the instances with the Mongo client and run the following command to configure the Replica Set.

```javascript
rs.initiate( { _id: 'config', members: [ { _id: 0, host: 'localhost:27031' }, { _id: 1, host: 'localhost:27032' }, { _id: 2, host: 'localhost:27033' } ] }
```

## Start the Router (Mongos)

Run the following Powershell Script

```Powershell
Start-Process -FilePath "C:\Program Files\MongoDB\Server\4.0\bin\mongos.exe" -ArgumentList "--configdb config/localhost:27031,localhost:27032,localhost:27033 --port 27040"
```

It needs to know the configuration Replica Set created earlier. The configdb param takes care of that.

## Start the mongo instances 

1. Run the following Powershell script.

```Powershell
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

```

2. Connect to one of the first three nodes (27050-27052) and initiate the Replica Set. 

```javascript
rs.initiate( { _id: 'store1', members: [ { _id: 0, host: 'localhost:27050' }, { _id: 1, host: 'localhost:27051' }, { _id: 2, host: 'localhost:27052' } ] } )
```

3. Connect to one of the last three nodes (27053-27055) and initiate the Replica Set.

```javascript
rs.initiate( { _id: 'store2', members: [ { _id: 0, host: 'localhost:27053' }, { _id: 1, host: 'localhost:27054' }, { _id: 2, host: 'localhost:27055' } ] } )
```

## Add shards to the cluster

Open a connection to the mongos instance created earlier, then add two shards (one for each shop) to the cluster's configuration with the following commands. 

```javascript
sh.addShard('store1/localhost:27050,localhost:27051,localhost:27052');
sh.addShard('store2/localhost:27054,localhost:27053,localhost:27055');
```

## Enable sharding for the Database and a collection

Open a connection to the mongos instance created earlier, then enable sharding at the db and collection levels with the following commands. (The database is named store and the collection is named sales).

```javascript
sh.enableSharding("store");
sh.shardCollection("store.sales", {storeId:1, deviceId:1});
```

The index will be composed of the tuple (storeId, deviceId), which we'll use in our zones definitions. 

This last step closes the instructions on the following article: https://docs.mongodb.com/manual/tutorial/deploy-shard-cluster/. Now on to the zones part. 

## Create zones and add shards to them

The rest of this article is based on https://docs.mongodb.com/manual/tutorial/sharding-segmenting-shards/ 

```javascript
sh.addShardTag('store1','1')
sh.addShardTag('store2','2')
sh.addTagRange('store.sales',{'storeId':'1','deviceId':MinKey}, {'storeId':'1','deviceId':MaxKey},'1')
sh.addTagRange('store.sales',{'storeId':'2','deviceId':MinKey}, {'storeId':'2','deviceId':MaxKey},'2')
```

## Test the distribution
Using the client app, add a few records to the sales collection, targeting different stores. __**The client app must connect to the mongos instance.**__
