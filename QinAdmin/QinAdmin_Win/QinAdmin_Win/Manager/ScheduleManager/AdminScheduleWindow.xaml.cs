using QinAdmin_Win.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using Excel = Microsoft.Office.Interop.Excel;

namespace QinAdmin_Win.ScheduleManager
{
    /// <summary>
    /// AdminScheduleWindow.xaml 的交互逻辑
    /// </summary>
    public partial class AdminScheduleWindow : Window
    {
        List<Schedule> Schedules;
        public AdminScheduleWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.LoadScheduleFromDB();
        }

        private void LoadScheduleFromDB()
        {
            //Room.Buildings = Building.GetAll();
            //Schedule.AllCourses = Course.GetAll();
            //Schedule.AllProfessors = Professor.GetAll();
            //Schedule.AllRooms = Room.GetAll();
            //Schedule.AllSections = Section.GetAll();
            //Schedule.AllStudents = Student.GetAll();
            Schedules = Schedule.GetAll();
            this.ScheduleDataGrid.ItemsSource = this.Schedules;
        }

        private void AddScheduleButton_Click(object sender, RoutedEventArgs e)
        {
            var newScheduleEditor = new ScheduleEditorWindow();
            newScheduleEditor.EditingSchedule = new Schedule();
            newScheduleEditor.EditingMode = ModelEditMode.Add;
            if (newScheduleEditor.ShowDialog() == true)
            {
                this.LoadScheduleFromDB();
            }
            else
            {
                MessageBox.Show("添加失败: {0}", newScheduleEditor.EditingSchedule.ToSearcheString());
            }
        }

        private void EditScheduleButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.ScheduleDataGrid.SelectedItem != null)
            {
                var editSchedule = this.ScheduleDataGrid.SelectedItem as Schedule;
                var newScheduleEditor = new ScheduleEditorWindow();
                newScheduleEditor.EditingSchedule = editSchedule.Copy();
                newScheduleEditor.EditingMode = ModelEditMode.Edit;
                if (newScheduleEditor.ShowDialog() == true)
                {
                    this.LoadScheduleFromDB();
                }
                else
                {
                    MessageBox.Show("修改失败: {0}", newScheduleEditor.EditingSchedule.ToSearcheString());
                }
            }
        }

        private void DeleteScheduleButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.ScheduleDataGrid.SelectedItem != null)
            {
                var deleteSchedule = this.ScheduleDataGrid.SelectedItem as Schedule;
                if (MessageBox.Show(String.Format("确定删除？ {0}", deleteSchedule.ToSearcheString()), "删除", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    if (deleteSchedule.Delete())
                    {
                        this.LoadScheduleFromDB();
                    }
                    else
                    {
                        MessageBox.Show("删除失败: {0}", deleteSchedule.ToSearcheString());
                    }
                }
            }
        }

        private void FilterButton_Click(object sender, RoutedEventArgs e)
        {
            this.ScheduleDataGrid.ItemsSource = null;
            this.ScheduleDataGrid.ItemsSource = this.Schedules.Where(t => t.ToSearcheString().Contains(this.KeywordTextBox.Text));
        }

        private void ExportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.FolderBrowserDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                new Task(() =>
                {
                    try
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在下载Excel文件"; }));
                        if (!DatabaseHelper.LCGetExcelFile("Schedule", @"Schedule.xlsx"))
                        {
                            MessageBox.Show("下载失败");
                        }
                        var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "Schedule.xlsx");
                        System.IO.File.Copy("Schedule.xlsx", des, true);
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在填充数据"; }));
                        var excelApplication = new Excel.Application();
                        excelApplication.Visible = true;
                        var workBook = excelApplication.Workbooks.Open(des);
                        var courseWorkSheet = (Excel.Worksheet)workBook.Worksheets[3];
                        for (int i = 1; i < courseWorkSheet.UsedRange.Rows.Count; i++)
                        {
                            courseWorkSheet.Cells[i, 1] = "";
                        }
                        for (int i = 1; i < Schedule.AllCourses.Count + 1; i++)
                        {
                            courseWorkSheet.Cells[i, 1] = Schedule.AllCourses[i - 1].ID + "." + Schedule.AllCourses[i - 1].Name;
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在填充课程数据 {0} / {1}", i, Schedule.AllCourses.Count); }));
                        }
                        var workSheet = (Excel.Worksheet)workBook.Worksheets[4];
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            workSheet.Cells[i, 1] = "";
                        }
                        for (int i = 1; i < Schedule.AllRooms.Count + 1; i++)
                        {
                            //workSheet.Cells[i, 1] = Schedule.AllRooms[i - 1].ID + "." + Schedule.AllRooms[i - 1].LocationName + Schedule.AllRooms[i - 1].Name;
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在填充房间数据 {0} / {1}", i, Schedule.AllRooms.Count); }));
                        }
                        var sectionWorkSheet = (Excel.Worksheet)workBook.Worksheets[5];
                        for (int i = 1; i < sectionWorkSheet.UsedRange.Rows.Count + 1; i++)
                        {
                            sectionWorkSheet.Cells[i, 1] = "";
                        }
                        for (int i = 1; i < Schedule.AllSections.Count; i++)
                        {
                            sectionWorkSheet.Cells[i, 1] = Schedule.AllSections[i - 1].ID + "." + Schedule.AllSections[i - 1].Name;
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在填充学时数据 {0} / {1}", i, Schedule.AllSections.Count); }));
                        }
                        workBook.Save();
                        System.Diagnostics.Process.Start(openFileDlg.SelectedPath);
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "下载成功"; }));
                    }
                    catch (Exception ex)
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("下载失败：{0}", ex.ToString()); }));
                    }
                }).Start();
            }
        }

        List<Schedule> ImportSchedules = new List<Schedule>();
        private void ImportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.OpenFileDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                new Task(() =>
                {
                    try
                    {
                        ImportSchedules = new List<Schedule>();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在读取Excel文件"; }));
                        var excelApplication = new Excel.Application();
                        excelApplication.Visible = false;
                        var workBook = excelApplication.Workbooks.Open(openFileDlg.FileName, ReadOnly: true);
                        var workSheet = (Excel.Worksheet)workBook.Worksheets[2];
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            String courseName = Convert.ToString(((Excel.Range)workSheet.Cells[i + 1, 1]).Value2);
                            var courseID = 0;
                            var getcourseID = int.TryParse(courseName.Split('.')[0], out courseID);
                            var course = Schedule.AllCourses.Where(t => t.ID.Equals(courseID)).ToList();
                            if (courseName.isEmptyOrNull() || getcourseID == false || course.Count != 1)
                            {
                                this.closeExcel(excelApplication, workBook, workSheet);
                                MessageBox.Show(String.Format("课程信息错误，错误行：{0} ，列：{1}\n\n", i + 1, 1), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }

                            String roomName = Convert.ToString(((Excel.Range)workSheet.Cells[i + 1, 2]).Value2);
                            var roomID = 0;
                            var getroomID = int.TryParse(roomName.Split('.')[0], out roomID);
                            var room = Schedule.AllRooms.Where(t => t.ID.Equals(roomID)).ToList();
                            if (roomName.isEmptyOrNull() || getroomID == false || room.Count != 1)
                            {
                                this.closeExcel(excelApplication, workBook, workSheet);
                                MessageBox.Show(String.Format("课程地点错误，错误行：{0} ，列：{1}\n\n", i + 1, 2), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }

                            String workingDateName = Convert.ToString(((Excel.Range)workSheet.Cells[i + 1, 3]).Value2);
                            if (workingDateName.ConvertToDateTime("YYYY-MM-dd") == null)
                            {
                                this.closeExcel(excelApplication, workBook, workSheet);
                                MessageBox.Show(String.Format("课程日期错误，错误行：{0} ，列：{1}\n\n", i + 1, 3), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }

                            String startTimeName = Convert.ToString(((Excel.Range)workSheet.Cells[i + 1, 4]).Value2);
                            var startTimeID = 0;
                            var getstartTimeID = int.TryParse(startTimeName.Split('.')[0], out startTimeID);
                            var startTime = Schedule.AllSections.Where(t => t.ID.Equals(startTimeID)).ToList();
                            if (startTimeName.isEmptyOrNull() || getstartTimeID == false || startTime.Count != 1)
                            {
                                this.closeExcel(excelApplication, workBook, workSheet);
                                MessageBox.Show(String.Format("课程起始节次错误，错误行：{0} ，列：{1}\n\n", i + 1, 4), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }

                            String endTimeName = Convert.ToString(((Excel.Range)workSheet.Cells[i + 1, 5]).Value2);
                            var endTimeID = 0;
                            var getendTimeID = int.TryParse(endTimeName.Split('.')[0], out endTimeID);
                            var endTime = Schedule.AllSections.Where(t => t.ID.Equals(endTimeID)).ToList();
                            if (endTimeName.isEmptyOrNull() || getendTimeID == false || endTime.Count != 1 || endTime.First().Order < startTime.First().Order)
                            {
                                this.closeExcel(excelApplication, workBook, workSheet);
                                MessageBox.Show(String.Format("课程结束节次错误，错误行：{0} ，列：{1}\n\n", i + 1, 5), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }

                            string sectionID = "";
                            for (int j = 0; j < endTime.First().Order - startTime.First().Order + 1; j++)
                            {
                                sectionID += "," + (startTime.First().Order + j);
                            }

                            ImportSchedules.Add(new Schedule() { CourseID = courseID, RoomID = roomID, WorkingDate = workingDateName, SectionID = sectionID, GroupsID = "", ProfsID = "", StudentsID = "" });
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        this.closeExcel(excelApplication, workBook, workSheet);
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("读取完毕，共 {0} 行", ImportSchedules.Count); this.ScheduleDataGrid.ItemsSource = ImportSchedules; }));
                    }
                    catch (Exception ex)
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传失败：{0}", ex.ToString()); }));
                    }
                }).Start();
            }
        }

        private void closeExcel(Excel.Application excelApplication, Excel.Workbook workBook, Excel.Worksheet workSheet)
        {
            workBook.Close(0);
            excelApplication.Quit();
            this.releaseObject(workSheet);
            this.releaseObject(workBook);
            this.releaseObject(excelApplication);
        }
        private void releaseObject(object obj)
        {
            try
            {
                System.Runtime.InteropServices.Marshal.ReleaseComObject(obj);
                obj = null;
            }
            catch  
            {
                obj = null;
                //MessageBox.Show("Unable to release the Object " + ex.ToString());
            }
            finally
            {
                GC.Collect();
            }
        }

        private void ReloadButton_Click(object sender, RoutedEventArgs e)
        {
            this.ScheduleDataGrid.ItemsSource = null;
            this.LoadScheduleFromDB();
        }

        private void UploadButton_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("是否确认上传当前Excel数据？", "上传新数据", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
            {
                new Task(() =>
                {
                    this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", 0, ImportSchedules.Count); }));
                    var badSchedules = "";
                    for (int i = 0; i < ImportSchedules.Count; i++)
                    {
                        if (ImportSchedules[i].Create())
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", i + 1, ImportSchedules.Count); }));
                        else
                            badSchedules += ImportSchedules[i].ID + " ";
                    }
                    if (badSchedules.Equals(""))
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传成功，共{0}条数据", ImportSchedules.Count); this.LoadScheduleFromDB(); }));
                    }
                    else
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("以下建筑上传失败 {0}", badSchedules); this.LoadScheduleFromDB(); }));
                    }
                }).Start();
            }
        }
    }
}
