using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public class Group
    {
        public String ID { get; set; }
        public String Name { get; set; }
        public String objectId { get; set; }

        [Newtonsoft.Json.JsonIgnore]
        public static List<Student> AllStudents { get; set; }

        public string ToSearcheString()
        {
            return String.Format("Group: {0}", Name);
        }

        public bool Create()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var createURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Group";
            return DatabaseHelper.LCCreate(createURL, jsonString);
        }

        public bool Update()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var updateURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Group/" + this.objectId;
            return DatabaseHelper.LCUpdate(updateURL, jsonString);
        }

        public bool Delete()
        {
            var deleteURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Group/" + this.objectId;
            return DatabaseHelper.LCDelete(deleteURL);
        }

        private static List<Group> groups = null;
        public static List<Group> GetAll(bool refreash)
        {
            try
            {
                if (groups == null || refreash == true)
                {
                    groups = new List<Group>();
                    var getGroups = new List<Group>();
                    do
                    {
                        var getAllGroupURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Group?order=ID&limit=1000&skip=" + groups.Count;
                        getGroups = (DatabaseHelper.LCSearch(getAllGroupURL)["results"] as JArray).ToObject<List<Group>>();
                        groups.AddRange(getGroups);
                    } while (getGroups.Count != 0);
                }
                return groups;
            }
            catch
            {
                return new List<Group>();
            }
        }
    }
}
