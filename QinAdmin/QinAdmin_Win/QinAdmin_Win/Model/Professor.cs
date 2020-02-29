using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public class Professor
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
            var createURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Professor";
            return DatabaseHelper.LCCreate(createURL, jsonString);
        }

        public bool Update()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var updateURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Professor/" + this.objectId;
            return DatabaseHelper.LCUpdate(updateURL, jsonString);
        }

        public bool Delete()
        {
            var deleteURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Professor/" + this.objectId;
            return DatabaseHelper.LCDelete(deleteURL);
        }

        private static List<Professor> professors = null;
        public static List<Professor> GetAll(bool refreash)
        {
            try
            {
                if (professors == null || refreash == true)
                {
                    professors = new List<Professor>();
                    var getprofessors = new List<Professor>();
                    do
                    {
                        var getAllprofessorURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Professor?order=ID&limit=1000&skip=" + professors.Count;
                        getprofessors = (DatabaseHelper.LCSearch(getAllprofessorURL)["results"] as JArray).ToObject<List<Professor>>();
                        professors.AddRange(getprofessors);
                    } while (getprofessors.Count != 0);
                }
                return professors;
            }
            catch
            {
                return new List<Professor>();
            }
        }
    }
}
