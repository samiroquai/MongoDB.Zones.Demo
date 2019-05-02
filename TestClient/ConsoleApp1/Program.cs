using System;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
            //port => the Mongos instance
            DataAccess da = new DataAccess("mongodb://localhost:27040");
            Task[] tasks = new Task[]
            {
                da.AddSaleAsync(new Sale(){ Amount=1000, deviceId=1, storeId=1, Remark="testStore 1 op1"}),
                da.AddSaleAsync(new Sale(){ Amount=1000, deviceId=2, storeId=1, Remark="testStore 1 op2"}),
                da.AddSaleAsync(new Sale(){ Amount=1000, deviceId=3, storeId=1, Remark="testStore 1 op3"}),
                da.AddSaleAsync(new Sale(){ Amount=1000, deviceId=1, storeId=2, Remark="testStore 2 op1"}),
                da.AddSaleAsync(new Sale(){ Amount=1000, deviceId=1, storeId=2, Remark="testStore 2 op2"}),
            };
            Task.WaitAll(tasks);
            Console.WriteLine("Initialization complete");
        }
    }
}
