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

namespace QinAdmin_Win.CourseManager
{
    /// <summary>
    /// AdminCourseWindow.xaml 的交互逻辑
    /// </summary>
    public partial class AdminCourseWindow : Window
    {
        List<Course> Courses;
        public AdminCourseWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.LoadCourseFromDB();
        }

        private void LoadCourseFromDB()
        {
            Courses = Course.GetAll(true);
            this.CourseDataGrid.ItemsSource = this.Courses;
        }

        private void AddCourseButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var newCourseEditor = new CourseEditorWindow();
            newCourseEditor.EditingCourse = new Course() { ID = "", Name = "", objectId = null };
                newCourseEditor.ShowDialog();
                this.LoadCourseFromDB();
                }
            catch
            {
                MessageBox.Show("添加失败");
            }
        }

        private void EditCourseButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.CourseDataGrid.SelectedItem != null)
            {
                try
                {
                    var editCourse = this.CourseDataGrid.SelectedItem as Course;
                var newCourseEditor = new CourseEditorWindow();
                    newCourseEditor.EditingCourse = editCourse;
      newCourseEditor.ShowDialog() ;
                    this.LoadCourseFromDB();
                    }
                catch
                {
                    MessageBox.Show("更新失败");
                }
            }
        }

        private void DeleteCourseButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.CourseDataGrid.SelectedItem != null)
            {
                var deleteCourse = this.CourseDataGrid.SelectedItem as Course;
                if (MessageBox.Show(String.Format("确定删除？ {0}", deleteCourse.ToSearcheString()), "删除", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    if (deleteCourse.Delete())
                    {
                        this.LoadCourseFromDB();
                    }
                    else
                    {
                        MessageBox.Show("删除失败: {0}", deleteCourse.ToSearcheString());
                    }
                }
            }
        }

        private void FilterButton_Click(object sender, RoutedEventArgs e)
        {
            this.CourseDataGrid.ItemsSource = null;
            this.CourseDataGrid.ItemsSource = this.Courses.Where(t => t.ToSearcheString().Contains(this.KeywordTextBox.Text));
        }

        private void ExportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.FolderBrowserDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "Course.xlsx");
                if (DatabaseHelper.LCGetExcelFile("Course", des))
                {
                    System.Diagnostics.Process.Start(openFileDlg.SelectedPath);
                }
                else
                {
                    MessageBox.Show("下载失败");
                }
            }
        }

        List<Course> ImportCourses = new List<Course>();
        private void ImportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.OpenFileDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                new Task(() =>
                {
                    try
                    {
                        ImportCourses = new List<Course>();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在读取Excel文件"; }));
                        var workSheet = ApplicationHelper.GetWorkSheetByName(openFileDlg.FileName, "数据表格");
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            ImportCourses.Add(new Course()
                            {
                                ID = workSheet.IsNullOrEmpty(i + 1, "课程编号", "课程编号错误"),
                                Name = workSheet.IsNullOrEmpty(i + 1, "课程名称", "课程名称错误")
                            });
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        workSheet.CloseApplication();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("读取完毕，共 {0} 行", ImportCourses.Count); this.CourseDataGrid.ItemsSource = ImportCourses; }));
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
            this.CourseDataGrid.ItemsSource = null;
            this.LoadCourseFromDB();
        }

        private void UploadButton_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("是否确认上传当前Excel数据？", "上传新数据", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
            {
                new Task(() =>
                {
                    this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", 0, ImportCourses.Count); }));
                    var badCourses = "";
                    for (int i = 0; i < ImportCourses.Count; i++)
                    {
                        if (ImportCourses[i].Create())
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", i + 1, ImportCourses.Count); }));
                        else
                            badCourses += ImportCourses[i].Name + " ";
                    }
                    if (badCourses.Equals(""))
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传成功，共{0}条数据", ImportCourses.Count); this.LoadCourseFromDB(); }));
                    }
                    else
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("以下建筑上传失败 {0}", badCourses); this.LoadCourseFromDB(); }));
                    }
                }).Start();
            }
        }

        private void DownLoadButton_Click(object sender, RoutedEventArgs e)
        {
            Excel.Worksheet worksheet = ApplicationHelper.CreateWorkSheet();
            worksheet.Cells[1, 1] = "课程编号";
            worksheet.Cells[1, 2] = "课程名称";
            var rowIndex = 2;
            foreach (var course in Course.GetAll(true))
            {
                worksheet.Cells[rowIndex, 1] = course.ID;
                worksheet.Cells[rowIndex, 2] = course.Name;
                rowIndex++;
            }
        }
    }
}
