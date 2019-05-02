using MongoDB.Bson.Serialization;
using MongoDB.Bson.Serialization.IdGenerators;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    class DataAccess
    {
        private readonly MongoClient client;
        private IMongoDatabase database;
        private bool _isInitialized = false;
        const string DBName = "store";
        const string CollectionName = "sales";

        public IMongoCollection<Sale> Collection { get; }

        public DataAccess(string connectionString)
        {
            client = new MongoClient(connectionString);
            database = client.GetDatabase(DBName);
            BsonClassMap.RegisterClassMap<Sale>(map =>
            {
                map.AutoMap();
                map.MapIdMember(c => c.id).SetIdGenerator(CombGuidGenerator.Instance);
            });
            Collection= database.GetCollection<Sale>(CollectionName);
        }

        public Task AddSaleAsync(Sale sale)
        {
            return Collection.InsertOneAsync(sale);
        }
    }
}
