using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public class ReStudentGroup
    {
        public String StudentID { get; set; }
        public String GroupID { get; set; }
        public String objectId { get; set; }

        Student student = null;

        [Newtonsoft.Json.JsonIgnore]
        public Student Student
        {
            get
            {
                if (student == null)
                {
                    student = Student.GetAll(false).Where(t => t.ID.Equals(this.StudentID)).FirstOrDefault();
                }
                return student ?? new Student() { ID = "", Name = "", Advertising = 0, BaiduFaceID = "", BLE = -1, objectId = null };
            }
            set
            {
                student = value;
                this.StudentID = student.ID;
            }
        }

        Group group = null;

        [Newtonsoft.Json.JsonIgnore]
        public Group Group
        {
            get
            {
                if (group == null)
                {
                    group = Group.GetAll(false).Where(t => t.ID.Equals(this.GroupID)).FirstOrDefault();
                }
                return group ?? new Group() { ID = "", Name = "", objectId = null };
            }
            set
            {
                group = value;
                this.GroupID = group.ID;
            }
        }


        public static ReStudentGroup CreateAndVertify(String StudentID, String GroupID)
        {
            var newRe = new ReStudentGroup() { StudentID = StudentID, GroupID = GroupID };
            if (newRe.Group.objectId == null || newRe.Student.objectId == null)
            {
                throw new Exception("班级编号或学生编号错误");
            }
            return newRe;
        }

        public string ToSearcheString()
        {
            return group.Name + student.Name;
        }

        public bool Create()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("StudentID", this.StudentID);
            jsonDic.Add("GroupID", this.GroupID);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var createURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/ReStudentGroup";
            return DatabaseHelper.LCCreate(createURL, jsonString);
        }

        public bool Update()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("StudentID", this.StudentID);
            jsonDic.Add("GroupID", this.GroupID);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var updateURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/ReStudentGroup/" + this.objectId;
            return DatabaseHelper.LCUpdate(updateURL, jsonString);
        }

        public bool Delete()
        {
            var deleteURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/ReStudentGroup/" + this.objectId;
            return DatabaseHelper.LCDelete(deleteURL);
        }

        private static List<ReStudentGroup> re_student_groups = null;
        public static List<ReStudentGroup> GetAll(bool refreash)
        {
            try
            {
                if (re_student_groups == null || refreash == true)
                {
                    re_student_groups = new List<ReStudentGroup>();
                    var getReStudentGroups = new List<ReStudentGroup>();
                    do
                    {
                        var getAllReStudentGroupURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/ReStudentGroup?order=ID&limit=1000&skip=" + re_student_groups.Count;
                        getReStudentGroups = (DatabaseHelper.LCSearch(getAllReStudentGroupURL)["results"] as JArray).ToObject<List<ReStudentGroup>>();
                        re_student_groups.AddRange(getReStudentGroups);
                    } while (getReStudentGroups.Count != 0);
                }
                return re_student_groups;
            }
            catch
            {
                return new List<ReStudentGroup>();
            }
        }
    }
}
