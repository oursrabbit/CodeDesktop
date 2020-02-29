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
        public ModelEditMode EditingMode;

        public bool IsSuccess = false;
        public ScheduleEditorWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            switch (EditingMode)
            {
                case ModelEditMode.Add:
                    this.ScheduleNameTextBox.Text = "";
                    break;
                case ModelEditMode.Edit:
                    this.LoadScheduleStudentFromDB();
                    break;
                default:
                    return;
            }
        }

        private void LoadScheduleStudentFromDB()
        {
            var Schedules = Schedule.GetAll();
            this.EditingSchedule = Schedules.Where(t => t.ID == this.EditingSchedule.ID).FirstOrDefault();
            this.ScheduleNameTextBox.Text = this.EditingSchedule.ScheduleProfessorsName;
            this.ScheduleStudentDataGrid.ItemsSource = this.EditingSchedule.StudentsInSchedule;
        }

        private void ExportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.FolderBrowserDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "Schedule_Student.xlsx");
                if (DatabaseHelper.LCGetExcelFile("Schedule_Student", des))
                {
                    System.Diagnostics.Process.Start(openFileDlg.SelectedPath);
                }
                else
                {
                    MessageBox.Show("下载失败");
                }
            }
        }

        Schedule ImportSchedules = new Schedule();
        List<Student> ImportStudents = new List<Student>();
        private void ImportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.OpenFileDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                new Task(() =>
                {
                    try
                    {
                        ImportSchedules = new Schedule();
                        ImportStudents = new List<Student>();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在读取Excel文件"; }));
                        var excelApplication = new Excel.Application();
                        excelApplication.Visible = false;
                        var workBook = excelApplication.Workbooks.Open(openFileDlg.FileName, ReadOnly: true);
                        var workSheet = (Excel.Worksheet)workBook.Worksheets[2];
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            String StudentSchoolID = Convert.ToString(((Excel.Range)workSheet.Cells[i + 1, 1]).Value2);
                            if (StudentSchoolID.isEmptyOrNull())
                            {
                                this.closeExcel(excelApplication, workBook, workSheet);
                                MessageBox.Show(String.Format("错误行：{0} ，列：{1}\n\n", i + 1, 1), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }
                            List<Student> StudentsInSchedule = Schedule.AllStudents.ToList<Student>();
                            if (StudentsInSchedule.Count != 1)
                            {
                                this.closeExcel(excelApplication, workBook, workSheet);
                                MessageBox.Show(String.Format("学生信息错误，错误行：{0} ，列：{1}\n\n", i + 1, 1), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }
                            ImportStudents.Add(StudentsInSchedule.First());
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        ImportSchedules.StudentsInSchedule = ImportStudents;
                        this.closeExcel(excelApplication, workBook, workSheet);
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("读取完毕，共 {0} 行", ImportStudents.Count()); this.ScheduleStudentDataGrid.ItemsSource = ImportSchedules.StudentsInSchedule; }));
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
            this.ScheduleStudentDataGrid.ItemsSource = null;
            this.LoadScheduleStudentFromDB();
        }

        private void UploadButton_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("是否确认上传当前Excel数据？", "上传新数据", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
            {
                if (!this.ScheduleNameTextBox.Text.isEmptyOrNull())
                {
                    switch (EditingMode)
                    {
                        case ModelEditMode.Add:
                            //this.DialogResult = (new Schedule() { Name = this.ScheduleNameTextBox.Text, Students = ImportSchedules.Students }.Create());
                            this.Close();
                            break;
                        case ModelEditMode.Edit:
                            //this.EditingSchedule.Name = this.ScheduleNameTextBox.Text;
                            //this.EditingSchedule.Students = ImportSchedules.Students;
                            this.DialogResult = this.EditingSchedule.Update();
                            this.Close();
                            break;
                        default:
                            return;
                    }
                }
            }
        }
    }
}
