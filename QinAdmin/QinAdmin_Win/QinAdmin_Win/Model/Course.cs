using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public class Course
    {
        public String ID { get; set; }
        public String Name { get; set; }

        public String objectId { get; set; }

        public string ToSearcheString()
        {
            return String.Format("Name: {0}", Name);
        }

        public bool Create()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var createURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Course";
            return DatabaseHelper.LCCreate(createURL, jsonString);
        }

        public bool Update()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var updateURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Course/" + this.objectId;
            return DatabaseHelper.LCUpdate(updateURL, jsonString);
        }

        public bool Delete()
        {
            var deleteURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Course/" + this.objectId;
            return DatabaseHelper.LCDelete(deleteURL);
        }

        private static List<Course> courses = null;
        public static List<Course> GetAll(bool refreash)
        {
            try
            {
                if (courses == null || refreash == true)
                {
                    courses = new List<Course>();
                    var getCourses = new List<Course>();
                    do
                    {
                        var getAllCourseURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Course?order=ID&limit=1000&skip=" + courses.Count;
                        getCourses = (DatabaseHelper.LCSearch(getAllCourseURL)["results"] as JArray).ToObject<List<Course>>();
                        courses.AddRange(getCourses);
                    } while (getCourses.Count != 0);
                }
                return courses;
            }
            catch
            {
                return new List<Course>();
            }
        }
    }
}
