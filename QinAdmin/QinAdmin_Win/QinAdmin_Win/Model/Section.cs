using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public class Section
    {
        public String ID { get; set; }
        public String Name { get; set; }

        public String objectId { get; set; }

        public String EndTime { get; set; }

        public String StartTime { get; set; }

        public int Order { get; set; }

        public string ToSearcheString()
        {
            return String.Format("Name: {0}", Name);
        }

        public bool Create()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            jsonDic.Add("EndTime", this.EndTime);
            jsonDic.Add("StartTime", this.StartTime);
            jsonDic.Add("Order", this.Order);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var createURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Section";
            return DatabaseHelper.LCCreate(createURL, jsonString);
        }

        public bool Update()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            jsonDic.Add("EndTime", this.EndTime);
            jsonDic.Add("StartTime", this.StartTime);
            jsonDic.Add("Order", this.Order);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var updateURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Section/" + this.objectId;
            return DatabaseHelper.LCUpdate(updateURL, jsonString);
        }

        public bool Delete()
        {
            var deleteURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Section/" + this.objectId;
            return DatabaseHelper.LCDelete(deleteURL);
        }

        private static List<Section> sections = null;
        public static List<Section> GetAll(bool refreash)
        {
            try
            {
                if (sections == null || refreash == true)
                {
                    sections = new List<Section>();
                    var getSections = new List<Section>();
                    do
                    {
                        var getAllSectionURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Section?order=Order&limit=1000&skip=" + sections.Count;
                        getSections = (DatabaseHelper.LCSearch(getAllSectionURL)["results"] as JArray).ToObject<List<Section>>();
                        sections.AddRange(getSections);
                    } while (getSections.Count != 0);
                }
                return sections;
            }
            catch
            {
                return new List<Section>();
            }
        }
    }
}
