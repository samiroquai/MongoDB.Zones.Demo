using System;
using System.Collections.Generic;
using System.Text;

namespace ConsoleApp1
{
    public class Sale
    {
        public Guid id { get; set; }
        public int storeId { get; set; }
        public int deviceId { get; set; }
        
        public decimal Amount { get; set; }
        public string Remark { get; set; }
    }
}
