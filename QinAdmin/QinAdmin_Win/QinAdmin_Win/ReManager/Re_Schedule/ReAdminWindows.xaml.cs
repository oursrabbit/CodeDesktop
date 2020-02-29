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

namespace QinAdmin_Win.ReManager.Re_Schedule
{
    /// <summary>
    /// ReAdminWindows.xaml 的交互逻辑
    /// </summary>
    public partial class ReAdminWindows : Window
    {
        List<Schedule> Relations;
        public ReAdminWindows()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.LoadRelationFromDB();
        }

        private void LoadRelationFromDB()
        {
            Relations = Schedule.GetAll(true);
            this.RelationDataGrid.ItemsSource = this.Relations;
        }

        private void AddReButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var newReEditor = new ReEditorWindow();
                newReEditor.EditRelation = new Schedule() { ID = "", CourseID ="", RoomID = "", StartDate = "", ContinueWeek = 0, StartSectionID = "", ContinueSection = 0, StudentID = "", ProfessorID = "", objectId = null };
                newReEditor.ShowDialog();
                this.LoadRelationFromDB();
            }
            catch
            {
                MessageBox.Show("添加失败");
            }
        }

        private void EditReButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (this.RelationDataGrid.SelectedItem is Schedule)
                {
                    var newReEditor = new ReEditorWindow();
                    newReEditor.EditRelation = this.RelationDataGrid.SelectedItem as Schedule;
                    newReEditor.ShowDialog();
                    this.LoadRelationFromDB();
                }
            }
            catch
            {
                MessageBox.Show("更新失败");
            }
        }

        private void DeleteReButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.RelationDataGrid.SelectedItem is Schedule)
            {
                var deleteRe = this.RelationDataGrid.SelectedItem as Schedule;
                if (MessageBox.Show(String.Format("确定删除？ {0}", deleteRe.ToSearcheString()), "删除", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    if (deleteRe.Delete())
                    {
                        this.LoadRelationFromDB();
                    }
                    else
                    {
                        MessageBox.Show("删除失败: {0}", deleteRe.ToSearcheString());
                    }
                }
            }
        }

        private void FilterButton_Click(object sender, RoutedEventArgs e)
        {
            this.RelationDataGrid.ItemsSource = null;
            this.RelationDataGrid.ItemsSource = this.Relations.Where(t => t.ToSearcheString().Contains(this.KeywordTextBox.Text));
        }

        private void ExportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.FolderBrowserDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "Schedule.xlsx");
                if (DatabaseHelper.LCGetExcelFile("Schedule", des))
                {
                    System.Diagnostics.Process.Start(openFileDlg.SelectedPath);
                }
                else
                {
                    MessageBox.Show("下载失败");
                }
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
                        var workSheet = ApplicationHelper.GetWorkSheetByName(openFileDlg.FileName, "数据表格");
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            ImportSchedules.Add(Schedule.CreateAndVertify(
                                 ID: workSheet.IsNullOrEmpty(i + 1, "日程编号", "日程编号错误")
                                , RoomID: workSheet.IsNullOrEmpty(i + 1, "教室编号", "教室编号错误")
                                , StartDateString: workSheet.IsNullOrEmpty(i + 1, "起始日期", "起始日期错误")
                                , ContinueWeek: workSheet.IsNullOrEmpty(i + 1, "持续次数", "持续次数错误")
                                , StartSectionID: workSheet.IsNullOrEmpty(i + 1, "起始节次编号", "起始节次错误")
                                , ContinueSection: workSheet.IsNullOrEmpty(i + 1, "持续节次", "持续节次错误")
                                , CourseID: workSheet.IsNullOrEmpty(i + 1, "课程编号", "课程名称错误")));
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        workSheet.CloseApplication();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("读取完毕，共 {0} 行", ImportSchedules.Count); this.RelationDataGrid.ItemsSource = ImportSchedules; }));
                    }
                    catch (Exception ex)
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传失败：{0}", ex.ToString()); }));
                    }
                }).Start();
            }
        }

        private void ReloadButton_Click(object sender, RoutedEventArgs e)
        {
            this.RelationDataGrid.ItemsSource = null;
            this.LoadRelationFromDB();
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
                            badSchedules += ImportSchedules[i].ToSearcheString() + " ";
                    }
                    if (badSchedules.Equals(""))
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传成功，共{0}条数据", ImportSchedules.Count); this.LoadRelationFromDB(); }));
                    }
                    else
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("以下上传失败 {0}", badSchedules); this.LoadRelationFromDB(); }));
                    }
                }).Start();
            }
        }

        private void DownLoadButton_Click(object sender, RoutedEventArgs e)
        {
            Excel.Worksheet worksheet = ApplicationHelper.CreateWorkSheet();
            worksheet.Cells[1, 1] = "日程编号";
            worksheet.Cells[1, 2] = "教室编号";
            worksheet.Cells[1, 3] = "教室名称";
            worksheet.Cells[1, 4] = "起始日期";
            worksheet.Cells[1, 5] = "持续次数";
            worksheet.Cells[1, 6] = "起始节次编号";
            worksheet.Cells[1, 7] = "起始节次";
            worksheet.Cells[1, 8] = "持续节次";
            worksheet.Cells[1, 9] = "课程编号";
            worksheet.Cells[1, 10] = "课程名称";
            var rowIndex = 2;
            foreach (var schedule in Schedule.GetAll(true))
            {
                worksheet.Cells[rowIndex, 1] = schedule.ID;
                worksheet.Cells[rowIndex, 2] = schedule.RoomID;
                worksheet.Cells[rowIndex, 3] = schedule.Room.Name;
                worksheet.Cells[rowIndex, 4] = schedule.StartDate;
                worksheet.Cells[rowIndex, 5] = schedule.ContinueWeek;
                worksheet.Cells[rowIndex, 6] = schedule.StartSectionID;
                worksheet.Cells[rowIndex, 7] = schedule.StartSection.Name;
                worksheet.Cells[rowIndex, 8] = schedule.ContinueSection;
                worksheet.Cells[rowIndex, 9] = schedule.CourseID;
                worksheet.Cells[rowIndex, 10] = schedule.Course.Name;
                rowIndex++;
            }
        }

        private void EditPeopleButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (this.RelationDataGrid.SelectedItem is Schedule)
                {
                    var newPeopleEditor = new ScheduleManager.ScheduleEditorWindow();
                    newPeopleEditor.EditingSchedule = this.RelationDataGrid.SelectedItem as Schedule;
                    newPeopleEditor.ShowDialog();
                    this.LoadRelationFromDB();
                }
            }
            catch
            {
                MessageBox.Show("更新失败");
            }
        }
    }
}
