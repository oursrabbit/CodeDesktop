using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public class Building
    {
        public String ID { get; set; }
        public String Name { get; set; }
        public String objectId { get; set; }

        public string ToSearcheString()
        {
            return String.Format("Name: {0}, ID:{1}", Name, ID);
        }

        public bool Create()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var createURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Building";
            return DatabaseHelper.LCCreate(createURL, jsonString);
        }

        public bool Update()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var updateURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Building/" + this.objectId;
            return DatabaseHelper.LCUpdate(updateURL, jsonString);
        }

        public bool Delete()
        {
            var deleteURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Building/" + this.objectId;
            return DatabaseHelper.LCDelete(deleteURL);
        }

        private static List<Building> buildings = null;
        public static List<Building> GetAll(bool refreash)
        {
            try
            {
                if (buildings == null || refreash == true)
                {
                    buildings = new List<Building>();
                    var getBuildings = new List<Building>();
                    do
                    {
                        var getAllBuildingURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Building?order=ID&limit=1000&skip=" + buildings.Count;
                        getBuildings = (DatabaseHelper.LCSearch(getAllBuildingURL)["results"] as JArray).ToObject<List<Building>>();
                        buildings.AddRange(getBuildings);
                    } while (getBuildings.Count != 0);
                }
                return buildings;
            }
            catch
            {
                return new List<Building>();
            }
        }
    }
}
