using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QinAdmin_Win.Model
{
    public class CheckRecording
    {
        public String StudentID { get; set; }

        public String RoomID { get; set; }

        public String CheckDate { get; set; }

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
                return student ?? new Student() { ID = "", Name = "", objectId = null };
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
                return room ?? new Room() { ID = "", Name = "", objectId = null };
            }
        }

        Schedule schedule = null;

        [Newtonsoft.Json.JsonIgnore]
        public Schedule Schedule
        {
            get
            {
                if (schedule == null)
                {
                    Schedule.GetAll(false).ForEach( t=> {
                        var checkDate = this.CheckDate.ConvertToDateTime("yyyy-MM-dd HH:mm:ss");

                    });
                }
                return schedule ?? new Schedule() { objectId = null };
            }
        }

        private static List<CheckRecording> checkRecordings = null;
        public static List<CheckRecording> GetAll(bool refreash)
        {
            try
            {
                if (checkRecordings == null || refreash == true)
                {
                    checkRecordings = new List<CheckRecording>();
                    var getCheckRecordings = new List<CheckRecording>();
                    do
                    {
                        var getAllCheckRecordingURL = DatabaseHelper.LeancloudAPIBaseURL + @"/1.1/classes/CheckRecording?order=ID&limit=1000&skip=" + checkRecordings.Count;
                        getCheckRecordings = (DatabaseHelper.LCSearch(getAllCheckRecordingURL)["results"] as JArray).ToObject<List<CheckRecording>>();
                        checkRecordings.AddRange(getCheckRecordings);
                    } while (getCheckRecordings.Count != 0);
                }
                return checkRecordings;
            }
            catch
            {
                return new List<CheckRecording>();
            }
        }
    }
}
