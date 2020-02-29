using QinAdmin_Win.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using Excel = Microsoft.Office.Interop.Excel;

namespace QinAdmin_Win.Manager.CheckRecordingManager
{
    /// <summary>
    /// AdminCheckRecordingWindow.xaml 的交互逻辑
    /// </summary>
    public partial class AdminCheckRecordingWindow : Window
    {
        List<CheckRecording> Relations;
        public AdminCheckRecordingWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.LoadRelationFromDB();
        }

        private void LoadRelationFromDB()
        {
            this.InfoLabel.Content = "正在加载数据...";
            new Task(new Action(() => {
                Relations = CheckRecording.GetAll(true);
                _ = Schedule.GetAll(true);

                this.Dispatcher.BeginInvoke(new Action(() => {
                    this.RelationDataGrid.ItemsSource = this.Relations;
                    this.CourseList.ItemsSource = Schedule.GetAll(false);
                    this.CourseList.DisplayMemberPath = "Course.Name";
                    this.InfoLabel.Content = "加载结束";
                }));
            })).Start();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            if (this.CourseList.SelectedItem is Schedule)
            {
                var selectedSchedule = this.CourseList.SelectedItem as Schedule;
                new Task(new Action(() => {
                    Excel.Worksheet worksheet = ApplicationHelper.CreateWorkSheet();
                    worksheet.Cells[1, 1] = "课程名称：" + selectedSchedule.Course.Name;
                    worksheet.Cells[2, 1] = "学号";
                    worksheet.Cells[2, 2] = "姓名";
                    for (int i = 0; i < selectedSchedule.ContinueWeek; i++)
                    {
                        worksheet.Cells[2, 3 + i] = "第" + (i +1).ToString() + "周";
                        var currentWeekStartCheckTime = (selectedSchedule.StartDate + " " + selectedSchedule.StartSection.StartTime).ConvertToDateTime("yyyy-MM-dd HH:mm").Value.AddDays(7 * i);
                        var currentWeekEndCheckTime = (selectedSchedule.StartDate + " " + selectedSchedule.EndSection.EndTime).ConvertToDateTime("yyyy-MM-dd HH:mm").Value.AddDays(7 * i);
                        for (int j = 0; j < selectedSchedule.Students.Count; j++)
                        {
                            var student = selectedSchedule.Students[j];
                            worksheet.Cells[3 + j, 1] = student.ID;
                            worksheet.Cells[3 + j, 2] = student.Name;
                            var ischeck = false;
                            foreach (var check in CheckRecording.GetAll(false).Where(t => t.StudentID.Equals(student.ID)))
                            {
                                var checkDate = check.CheckDate.ConvertToDateTime("yyyy-MM-dd HH:mm:ss").Value;
                                if (checkDate.IsInTimeSpan(currentWeekStartCheckTime, currentWeekEndCheckTime))
                                {
                                    if (check.RoomID.Equals(selectedSchedule.RoomID))
                                    {
                                        worksheet.Cells[3 + j, 3 + i] = "签到";
                                        ischeck = true;
                                        break;
                                    }
                                }
                            }
                            if (ischeck == false)
                            {
                                worksheet.Cells[3 + j, 3 + i] = "缺勤";
                                worksheet.Cells[3 + j, 3 + i].Font.Bold = true;
                            }
                        }
                    }
                })).Start();
            }
        }
    }
}
