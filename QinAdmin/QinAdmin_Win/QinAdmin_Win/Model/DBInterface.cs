using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public interface DBInterface
    {
        String objectId { get; set; }
        String ID { get; set; }
        String Name { get; set; }
        string ToSearcheString();
        void UpdateOrCreate();
        void Delete();
        List<DBInterface> GetAll(bool refreash);
    }
}
