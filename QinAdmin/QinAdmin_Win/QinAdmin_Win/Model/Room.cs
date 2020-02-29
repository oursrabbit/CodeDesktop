using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public class Room
    {
        public String ID { get; set; }
        public String Name { get; set; }
        public int BLE { get; set; }
        public String objectId { get; set; }

        public string ToSearcheString()
        {
            return String.Format("Name: {0} BLE:{1}", Name, BLE);
        }

        public bool Create()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            jsonDic.Add("BLE", this.BLE);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var createURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Room";
            return DatabaseHelper.LCCreate(createURL, jsonString);
        }

        public bool Update()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            jsonDic.Add("BLE", this.BLE);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var updateURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Room/" + this.objectId;
            return DatabaseHelper.LCUpdate(updateURL, jsonString);
        }

        public bool Delete()
        {
            var deleteURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Room/" + this.objectId;
            return DatabaseHelper.LCDelete(deleteURL);
        }

        private static List<Room> rooms = null;
        public static List<Room> GetAll(bool refreash)
        {
            try
            {
                if (rooms == null || refreash == true)
                {
                    rooms = new List<Room>();
                    var getrooms = new List<Room>();
                    do
                    {
                        var getAllroomURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Room?order=ID&limit=1000&skip=" + rooms.Count;
                        getrooms = (DatabaseHelper.LCSearch(getAllroomURL)["results"] as JArray).ToObject<List<Room>>();
                        rooms.AddRange(getrooms);
                    } while (getrooms.Count != 0);
                }
                return rooms;
            }
            catch
            {
                return new List<Room>();
            }
        }
    }
}
