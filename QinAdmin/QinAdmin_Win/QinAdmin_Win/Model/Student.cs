using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public class Student
    {
        public String ID { get; set; }
        public String Name { get; set; }
        public String BaiduFaceID { get; set; }
        public int Advertising { get; set; }
        public int BLE { get; set; }
        public String objectId { get; set; }

        public string ToSearcheString()
        {
            return String.Format("Name: {0} SchoolID: {1} BLE: {2}", Name, ID, BLE);
        }

        public bool Create()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            jsonDic.Add("BLE", this.BLE);
            jsonDic.Add("Advertising", 0);
            jsonDic.Add("BaiduFaceID", this.BaiduFaceID);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var createURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Student";
            return DatabaseHelper.LCCreate(createURL, jsonString);
        }

        public bool Update()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("Name", this.Name);
            jsonDic.Add("BLE", this.BLE);
            jsonDic.Add("Advertising", 0);
            jsonDic.Add("BaiduFaceID", this.BaiduFaceID);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var updateURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Student/" + this.objectId;
            return DatabaseHelper.LCUpdate(updateURL, jsonString);
        }

        public bool Delete()
        {
            var deleteURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Student/" + this.objectId;
            return DatabaseHelper.LCDelete(deleteURL);
        }

        private static List<Student> students = null;
        public static List<Student> GetAll(bool refreash)
        {
            try
            {
                if (students == null || refreash == true)
                {
                    students = new List<Student>();
                    var getstudents = new List<Student>();
                    do
                    {
                        var getAllstudentURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Student?order=ID&limit=1000&skip=" + students.Count;
                        getstudents = (DatabaseHelper.LCSearch(getAllstudentURL)["results"] as JArray).ToObject<List<Student>>();
                        students.AddRange(getstudents);
                    } while (getstudents.Count != 0);
                }
                return students;
            }
            catch
            {
                return new List<Student>();
            }
        }
    }
}
