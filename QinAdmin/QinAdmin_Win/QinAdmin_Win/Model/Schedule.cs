using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public class Schedule
    {
        public String ID { get; set; }
        public String StartDate { get; set; }
        public int ContinueWeek { get; set; }
        public String StartSectionID { get; set; }
        public int ContinueSection { get; set; }
        public String RoomID { get; set; }
        public String CourseID { get; set; }
        public String ProfessorID { get; set; }
        public String StudentID { get; set; }
        public String objectId { get; set; }

        Section startSection = null;

        [Newtonsoft.Json.JsonIgnore]
        public Section StartSection
        {
            get
            {
                if (startSection == null)
                {
                    startSection = Section.GetAll(false).Where(t => t.ID.Equals(this.StartSectionID)).FirstOrDefault();
                }
                return startSection ?? new Section() { ID = "", Name = "", StartTime = "00:00", EndTime = "00:00", Order = -1, objectId = null };
            }
            set
            {
                startSection = value;
                this.StartSectionID = startSection.ID;
            }
        }

        Section endSection = null;

        [Newtonsoft.Json.JsonIgnore]
        public Section EndSection
        {
            get
            {
                if (endSection == null)
                {
                    endSection = Section.GetAll(false).Where(t => t.Order.Equals(this.StartSection.Order + ContinueSection - 1)).FirstOrDefault();
                }
                return endSection ?? new Section() { ID = "", Name = "", StartTime = "00:00", EndTime = "00:00", Order = -1, objectId = null };
            }
            set
            {
                endSection = value;
                this.ContinueSection = endSection.Order - this.StartSection.Order + 1;
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

        Course course = null;

        [Newtonsoft.Json.JsonIgnore]
        public Course Course
        {
            get
            {
                if (course == null)
                {
                    course = Course.GetAll(false).Where(t => t.ID.Equals(this.CourseID)).FirstOrDefault();
                }
                return course ?? new Course() { ID = "", Name = "",  objectId = null };
            }
            set
            {
                course = value;
                this.CourseID = course.ID;
            }
        }

        List<Student> students = null;

        [Newtonsoft.Json.JsonIgnore]
        public List<Student> Students
        {
            get
            {
                if (students == null)
                {
                    students = new List<Student>();
                    foreach (var studentID in this.StudentID.Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries))
                    {
                        var student = Student.GetAll(false).Where(t => t.ID.Equals(studentID)).FirstOrDefault();
                        if (student == null)
                        {
                            students = null;
                            return students;
                        }
                        students.Add(student);
                    }
                }
                return students;
            }
            set
            {
                students = value;
                this.StudentID = "";
                foreach (var student in students)
                {
                    this.StudentID += student.ID + ";";
                }
                this.StudentID = this.StudentID.RemoveLast();
            }
        }

        List<Professor> professors = null;

        [Newtonsoft.Json.JsonIgnore]
        public List<Professor> Professors
        {
            get
            {
                if (professors == null)
                {
                    professors = new List<Professor>();
                    foreach (var professorID in this.ProfessorID.Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries))
                    {
                        var professor = Professor.GetAll(false).Where(t => t.ID.Equals(professorID)).FirstOrDefault();
                        if (professor == null)
                        {
                            professors = null;
                            return professors;
                        }
                        professors.Add(professor);
                    }
                }
                return professors;
            }
            set
            {
                professors = value;
                this.ProfessorID = "";
                foreach (var professor in professors)
                {
                    this.ProfessorID += professor.ID + ";";
                }
                this.ProfessorID = this.ProfessorID.RemoveLast();
            }
        }

        public static Schedule CreateAndVertify(String ID, String StartDateString, String ContinueWeek, String StartSectionID, String ContinueSection, String RoomID, String CourseID)
        {
            if (ID.isEmptyOrNull() == true)
            {
                throw new Exception("课表编号错误");
            }
            var StartDate = StartDateString.ConvertToDateTime("yyyy-MM-dd");
            if (StartDate == null)
            {
                throw new Exception("课程起始日期错误");
            }
            var ContinueWeekNumber = ContinueWeek.ConvertToInt();
            if(ContinueWeekNumber == null)
            {
                throw new Exception("课表持续周数错误");
            }
            var ContinueSectionNumber = ContinueSection.ConvertToInt();
            if (ContinueSectionNumber == null)
            {
                throw new Exception("课表持续课时数错误");
            }
            var newSchedule = new Schedule() { StartSectionID = StartSectionID, RoomID = RoomID, CourseID = CourseID, StudentID = "", ProfessorID = "", ID = ID, StartDate = StartDateString, ContinueWeek = ContinueSectionNumber.Value, ContinueSection = ContinueSectionNumber.Value, objectId = null };
            if (newSchedule.StartSection.objectId == null)
            {
                throw new Exception("课程起始节次错误");
            }
            if (newSchedule.Room.objectId == null)
            {
                throw new Exception("课程房间错误");
            }
            if (newSchedule.Course.objectId == null)
            {
                throw new Exception("课程错误");
            }
            return newSchedule;
        }

        public string ToSearcheString()
        {
            var studentsName = "";
            Students.ForEach(t => studentsName += t.Name + " ");
            var prosName = "";
            Professors.ForEach(t => prosName += t.Name + " ");
            return Course.Name + Room.Name + prosName + studentsName;
        }

        public bool Create()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("StartDate", this.StartDate);
            jsonDic.Add("ContinueWeek", this.ContinueWeek);
            jsonDic.Add("StartSectionID", this.StartSectionID);
            jsonDic.Add("ContinueSection", this.ContinueSection);
            jsonDic.Add("RoomID", this.RoomID);
            jsonDic.Add("CourseID", this.CourseID);
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("ProfessorID", this.ProfessorID);
            jsonDic.Add("StudentID", this.StudentID);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var createURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Schedule";
            return DatabaseHelper.LCCreate(createURL, jsonString);
        }

        public bool Update()
        {
            var jsonDic = new Dictionary<String, Object>();
            jsonDic.Add("StartDate", this.StartDate);
            jsonDic.Add("ContinueWeek", this.ContinueWeek);
            jsonDic.Add("StartSectionID", this.StartSectionID);
            jsonDic.Add("ContinueSection", this.ContinueSection);
            jsonDic.Add("RoomID", this.RoomID);
            jsonDic.Add("CourseID", this.CourseID);
            jsonDic.Add("ID", this.ID);
            jsonDic.Add("ProfessorID", this.ProfessorID);
            jsonDic.Add("StudentID", this.StudentID);
            var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);
            var updateURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Schedule/" + this.objectId;
            return DatabaseHelper.LCUpdate(updateURL, jsonString);
        }

        public bool Delete()
        {
            var deleteURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Schedule/" + this.objectId;
            return DatabaseHelper.LCDelete(deleteURL);
        }

        private static List<Schedule> schedules = null;
        public static List<Schedule> GetAll(bool refreash)
        {
            try
            {
                if (schedules == null || refreash == true)
                {
                    schedules = new List<Schedule>();
                    var getSchedules = new List<Schedule>();
                    do
                    {
                        var getAllScheduleURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/Schedule?order=ID&limit=1000&skip=" + schedules.Count;
                        getSchedules = (DatabaseHelper.LCSearch(getAllScheduleURL)["results"] as JArray).ToObject<List<Schedule>>();
                        schedules.AddRange(getSchedules);
                    } while (getSchedules.Count != 0);
                }
                return schedules;
            }
            catch
            {
                return new List<Schedule>();
            }
        }
    }
}
