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

namespace QinAdmin_Win.StudentManager
{
    /// <summary>
    /// AdminStudentWindow.xaml 的交互逻辑
    /// </summary>
    public partial class AdminStudentWindow : Window
    {
        List<Student> Students;
        public AdminStudentWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.LoadStudentFromDB();
        }

        private void LoadStudentFromDB()
        {
            Students = Student.GetAll(true);
            this.StudentDataGrid.ItemsSource = this.Students;
        }

        private void AddStudentButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var newStudentEditor = new StudentEditorWindow();
            newStudentEditor.EditingStudent = new Student();
               newStudentEditor.ShowDialog();
                this.LoadStudentFromDB();
                }
            catch
            {
                MessageBox.Show("添加失败");
            }
        }

        private void EditStudentButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.StudentDataGrid.SelectedItem != null)
            {
                try
                {
                    var editStudent = this.StudentDataGrid.SelectedItem as Student;
                    var newStudentEditor = new StudentEditorWindow();
                    newStudentEditor.EditingStudent = editStudent;
                    newStudentEditor.ShowDialog();
                    this.LoadStudentFromDB();
                }
                catch
                {
                    MessageBox.Show("修改失败");
                }
            }
        }

        private void DeleteStudentButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.StudentDataGrid.SelectedItem != null)
            {
                var deleteStudent = this.StudentDataGrid.SelectedItem as Student;
                if (MessageBox.Show(String.Format("确定删除？ {0}", deleteStudent.ToSearcheString()), "删除", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    if (deleteStudent.Delete())
                    {
                        this.LoadStudentFromDB();
                    }
                    else
                    {
                        MessageBox.Show("删除失败: {0}", deleteStudent.ToSearcheString());
                    }
                }
            }
        }

        private void FilterButton_Click(object sender, RoutedEventArgs e)
        {
            this.StudentDataGrid.ItemsSource = null;
            this.StudentDataGrid.ItemsSource = this.Students.Where(t => t.ToSearcheString().Contains(this.KeywordTextBox.Text));
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
                        if (!DatabaseHelper.LCGetExcelFile("Student", @"Student.xlsx"))
                        {
                            MessageBox.Show("下载失败");
                        }
                        var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "Student.xlsx");
                        System.IO.File.Copy("Student.xlsx", des, true);
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
                        ImportStudents = new List<Student>();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在读取Excel文件"; }));
                        var workSheet = ApplicationHelper.GetWorkSheetByName(openFileDlg.FileName, "数据表格");
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            ImportStudents.Add(new Student()
                            {
                                ID = workSheet.IsNullOrEmpty(i + 1, "学生编号", "学生编号错误"),
                                Name = workSheet.IsNullOrEmpty(i + 1, "姓名", "姓名错误"),
                                BLE = workSheet.IsNumber(i + 1, "学生签到码", "学生签到码错误"),
                                Advertising =0,
                                BaiduFaceID = workSheet.IsNullOrEmpty(i + 1, "百度人脸编号", "百度人脸编号错误"),
                            });
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        workSheet.CloseApplication();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("读取完毕，共 {0} 行", ImportStudents.Count); this.StudentDataGrid.ItemsSource = ImportStudents; }));
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
            this.StudentDataGrid.ItemsSource = null;
            this.LoadStudentFromDB();
        }

        private void UploadButton_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("是否确认上传当前Excel数据？", "上传新数据", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
            {
                new Task(() =>
                {
                    this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", 0, ImportStudents.Count); }));
                    var badStudents = "";
                    for (int i = 0; i < ImportStudents.Count; i++)
                    {
                        if (ImportStudents[i].Create())
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", i + 1, ImportStudents.Count); }));
                        else
                            badStudents += ImportStudents[i].Name + " ";
                    }
                    if (badStudents.Equals(""))
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传成功，共{0}条数据", ImportStudents.Count); this.LoadStudentFromDB(); }));
                    }
                    else
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("以下建筑上传失败 {0}", badStudents); this.LoadStudentFromDB(); }));
                    }
                }).Start();
            }
        }
        private void DownLoadButton_Click(object sender, RoutedEventArgs e)
        {
            Excel.Worksheet worksheet = ApplicationHelper.CreateWorkSheet();
            worksheet.Cells[1, 1] = "学生编号";
            worksheet.Cells[1, 2] = "姓名";
            worksheet.Cells[1, 3] = "学生签到码";
            worksheet.Cells[1, 4] = "百度人脸编号";
            var rowIndex = 2;
            foreach (var student in Student.GetAll(true))
            {
                worksheet.Cells[rowIndex, 1] = student.ID;
                worksheet.Cells[rowIndex, 2] = student.Name;
                worksheet.Cells[rowIndex, 3] = student.BLE;
                worksheet.Cells[rowIndex, 4] = student.BaiduFaceID;
                rowIndex++;
            }
        }
    }
}
