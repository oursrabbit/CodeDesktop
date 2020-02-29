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

namespace QinAdmin_Win.ScheduleManager
{
    /// <summary>
    /// ScheduleEditorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class ScheduleEditorWindow : Window
    {
        public Schedule EditingSchedule;
        public ScheduleEditorWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.ProfessorIDTextBox.Text = "";
            foreach (var professor in this.EditingSchedule.Professors)
            {
                this.ProfessorIDTextBox.Text += professor.ID + ";";
            }
            this.ProfessorIDTextBox.Text = this.ProfessorIDTextBox.Text.RemoveLast();

            this.ScheduleStudentDataGrid.ItemsSource = this.EditingSchedule.Students;
        }

        private void ExportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.FolderBrowserDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "ReSchedulePeople.xlsx");
                if (DatabaseHelper.LCGetExcelFile("ReSchedulePeople", des))
                {
                    System.Diagnostics.Process.Start(openFileDlg.SelectedPath);
                }
                else
                {
                    MessageBox.Show("下载失败");
                }
            }
        }

        List<Professor> importProfessors = new List<Professor>();
        List<Student> importStudents = new List<Student>();
        private void ImportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.OpenFileDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                new Task(() =>
                {
                    try
                    {
                        importProfessors = new List<Professor>();
                        importStudents = new List<Student>();
                        var professorID = "";
                        var studentID = "";
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在读取Excel文件"; }));
                        var workSheet = ApplicationHelper.GetWorkSheetByName(openFileDlg.FileName, "数据表格");
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            string pid = Convert.ToString(((Excel.Range)workSheet.Cells[i + 1, 1]).Value2);
                            if (pid != null)
                            {
                                if (Professor.GetAll(false).Where(t => t.ID.Equals(pid)).Count() == 1)
                                {
                                    professorID += pid + ";";
                                    importProfessors.Add(Professor.GetAll(false).Where(t => t.ID.Equals(pid)).First());
                                }
                                else
                                {
                                    MessageBox.Show(String.Format("教师编号错误，第{0}行", i + 1));
                                    workSheet.CloseApplication();
                                    return;
                                }

                            }

                            string sid = Convert.ToString(((Excel.Range)workSheet.Cells[i + 1, 2]).Value2);
                            if (sid != null)
                            {
                                if (Student.GetAll(false).Where(t => t.ID.Equals(sid)).Count() == 1)
                                {
                                    studentID += sid + ";";
                                    importStudents.Add(Student.GetAll(false).Where(t => t.ID.Equals(sid)).First());
                                }
                                else
                                {
                                    MessageBox.Show(String.Format("学生编号错误，第{0}行", i + 1));
                                    workSheet.CloseApplication();
                                    return;
                                }

                            }
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        workSheet.CloseApplication();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "读取完毕"; this.ScheduleStudentDataGrid.ItemsSource = importStudents; this.ProfessorIDTextBox.Text = professorID.RemoveLast(); }));
                    }
                    catch (Exception ex)
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传失败：{0}", ex.ToString()); }));
                    }
                }).Start();
            }
        }

        private void UploadButton_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("是否确认上传当前Excel数据？", "上传新数据", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
            {
                this.EditingSchedule.Professors = importProfessors;
                this.EditingSchedule.Students = importStudents;
                this.EditingSchedule.Update();
                this.Close();
            }
        }

        private void DeleteAllButton_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("是否清除所有人员信息？", "删除", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
            {
                this.EditingSchedule.ProfessorID = "";
                this.EditingSchedule.StudentID = "";
                this.EditingSchedule.Update();
                this.Close();
            }
        }

        private void DownLoadButton_Click(object sender, RoutedEventArgs e)
        {
            Excel.Worksheet worksheet = ApplicationHelper.CreateWorkSheet();
            worksheet.Cells[1, 1] = "日程编号：";
            worksheet.Cells[2, 1] = "教室编号：";
            worksheet.Cells[3, 1] = "教室名称：";
            worksheet.Cells[4, 1] = "起始日期：";
            worksheet.Cells[5, 1] = "持续次数：";
            worksheet.Cells[6, 1] = "起始节次编号：";
            worksheet.Cells[7, 1] = "起始节次：";
            worksheet.Cells[8, 1] = "持续节次：";
            worksheet.Cells[9, 1] = "课程编号：";
            worksheet.Cells[10, 1] = "课程名称：";
            worksheet.Cells[11, 1] = "任课教师编号";
            worksheet.Cells[11, 2] = "任课教师名称";
            worksheet.Cells[11, 3] = "学生编号";
            worksheet.Cells[11, 4] = "学生名称";

            worksheet.Cells[1, 2] = this.EditingSchedule.ID;
            worksheet.Cells[2, 2] = EditingSchedule.RoomID;
            worksheet.Cells[3, 2] = EditingSchedule.Room.Name;
            worksheet.Cells[4, 2] = EditingSchedule.StartDate;
            worksheet.Cells[5, 2] = EditingSchedule.ContinueWeek;
            worksheet.Cells[6, 2] = EditingSchedule.StartSectionID;
            worksheet.Cells[7, 2] = EditingSchedule.StartSection.Name;
            worksheet.Cells[8, 2] = EditingSchedule.ContinueSection;
            worksheet.Cells[9, 2] = EditingSchedule.CourseID;
            worksheet.Cells[10, 2] = EditingSchedule.Course.Name;

            var rowIndex = 12;
            foreach (var professor in EditingSchedule.Professors)
            {
                worksheet.Cells[rowIndex, 1] = professor.ID;
                worksheet.Cells[rowIndex, 2] = professor.Name;
                rowIndex++;
            }

            rowIndex = 12;
            foreach (var student in EditingSchedule.Students)
            {
                worksheet.Cells[rowIndex, 3] = student.ID;
                worksheet.Cells[rowIndex, 4] = student.Name;
                rowIndex++;
            }
        }
    }
}
