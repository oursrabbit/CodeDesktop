using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public class ReBuildingRoom
    {
        public String BuildingID { get; set; }
        public String RoomID { get; set; }
        public String objectId { get; set; }

        Building building = null;

        [Newtonsoft.Json.JsonIgnore]
        public Building Building
        {
            get
            {
                if (building == null)
                {
                    building = Building.GetAll(false).Where(t => t.ID.Equals(this.BuildingID)).FirstOrDefault();
                }
                return building ?? new Building() { ID = "", Name = "", objectId = null };
            }
            set
            {
                building = value;
                this.BuildingID = building.ID;
            }
        }

        Room room = null;

        [Newtonsoft.Json.JsonIgnore]
        public Room Room
        {
            get
            {
                if (room == null)
                {
                    room = Room.GetAll(false).Where(t => t.ID.Equals(this.RoomID)).FirstOrDefault();
                }
                return room ?? new Room() { ID = "", Name = "", BLE = -1, objectId = null };
            }
            set
            {
                room = value;
                this.RoomID = room.ID;
            }
        }


        public static ReBuildingRoom CreateAndVertify(String BuildingID, String RoomID)
        {
            var newRe = new ReBuildingRoom() { BuildingID = BuildingID, RoomID = RoomID };
            if (newRe.Room.objectId == null || newRe.Building.objectId == null)
            {
                throw new Exception("房间号或建筑号错误");
            }
            return newRe;
        }

        public string ToSearcheString()
        {
            return room.Name + building.Name;
        }

        public bool Create()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("BuildingID", this.BuildingID);
            jsonDic.Add("RoomID", this.RoomID);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var createURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/ReBuildingRoom";
            return DatabaseHelper.LCCreate(createURL, jsonString);
        }

        public bool Update()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("BuildingID", this.BuildingID);
            jsonDic.Add("RoomID", this.RoomID);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var updateURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/ReBuildingRoom/" + this.objectId;
            return DatabaseHelper.LCUpdate(updateURL, jsonString);
        }

        public bool Delete()
        {
            var deleteURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/ReBuildingRoom/" + this.objectId;
            return DatabaseHelper.LCDelete(deleteURL);
        }

        private static List<ReBuildingRoom> re_building_rooms = null;
        public static List<ReBuildingRoom> GetAll(bool refreash)
        {
            try
            {
                if (re_building_rooms == null || refreash == true)
                {
                    re_building_rooms = new List<ReBuildingRoom>();
                    var getReBuildingRooms = new List<ReBuildingRoom>();
                    do
                    {
                        var getAllReBuildingRoomURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/ReBuildingRoom?order=ID&limit=1000&skip=" + re_building_rooms.Count;
                        getReBuildingRooms = (DatabaseHelper.LCSearch(getAllReBuildingRoomURL)["results"] as JArray).ToObject<List<ReBuildingRoom>>();
                        re_building_rooms.AddRange(getReBuildingRooms);
                    } while (getReBuildingRooms.Count != 0);
                }
                return re_building_rooms;
            }
            catch
            {
                return new List<ReBuildingRoom>();
            }
        }
    }
}
