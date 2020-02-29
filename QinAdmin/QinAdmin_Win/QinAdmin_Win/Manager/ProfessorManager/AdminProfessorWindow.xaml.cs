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

namespace QinAdmin_Win.ProfessorManager
{
    /// <summary>
    /// AdminProfessorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class AdminProfessorWindow : Window
    {
        List<Professor> Professors;
        public AdminProfessorWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.LoadProfessorFromDB();
        }

        private void LoadProfessorFromDB()
        {
            Professors = Professor.GetAll(true);
            this.ProfessorDataGrid.ItemsSource = this.Professors;
        }

        private void AddProfessorButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var newProfessorEditor = new ProfessorEditorWindow();
                newProfessorEditor.EditingProfessor = new Professor() { ID = "", Name = "", objectId = null };
                newProfessorEditor.ShowDialog();
                this.LoadProfessorFromDB();
            }
            catch
            {
                MessageBox.Show("添加失败");
            }
        }

        private void EditProfessorButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.ProfessorDataGrid.SelectedItem != null)
            {
                try
                {
                    var editProfessor = this.ProfessorDataGrid.SelectedItem as Professor;
                    var newProfessorEditor = new ProfessorEditorWindow();
                    newProfessorEditor.EditingProfessor = editProfessor;
                    newProfessorEditor.ShowDialog();
                    this.LoadProfessorFromDB();
                }
                catch
                {
                    MessageBox.Show("更新失败");
                }
            }
        }

        private void DeleteProfessorButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.ProfessorDataGrid.SelectedItem != null)
            {
                var deleteProfessor = this.ProfessorDataGrid.SelectedItem as Professor;
                if (MessageBox.Show(String.Format("确定删除？ {0}", deleteProfessor.ToSearcheString()), "删除", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    if (deleteProfessor.Delete())
                    {
                        this.LoadProfessorFromDB();
                    }
                    else
                    {
                        MessageBox.Show("删除失败: {0}", deleteProfessor.ToSearcheString());
                    }
                }
            }
        }

        private void FilterButton_Click(object sender, RoutedEventArgs e)
        {
            this.ProfessorDataGrid.ItemsSource = null;
            this.ProfessorDataGrid.ItemsSource = this.Professors.Where(t => t.ToSearcheString().Contains(this.KeywordTextBox.Text));
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
                        if (!DatabaseHelper.LCGetExcelFile("Professor", @"Professor.xlsx"))
                        {
                            MessageBox.Show("下载失败");
                        }
                        var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "Professor.xlsx");
                        System.IO.File.Copy("Professor.xlsx", des, true);
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

        List<Professor> ImportProfessors = new List<Professor>();
        private void ImportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.OpenFileDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                new Task(() =>
                {
                    try
                    {
                        ImportProfessors = new List<Professor>();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在读取Excel文件"; }));
                        var workSheet = ApplicationHelper.GetWorkSheetByName(openFileDlg.FileName, "数据表格");
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            ImportProfessors.Add(new Professor()
                            {
                                ID = workSheet.IsNullOrEmpty(i + 1, "教师编号", "教师编号错误"),
                                Name = workSheet.IsNullOrEmpty(i + 1, "姓名", "姓名错误")
                            });
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        workSheet.CloseApplication();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("读取完毕，共 {0} 行", ImportProfessors.Count); this.ProfessorDataGrid.ItemsSource = ImportProfessors; }));
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
            this.ProfessorDataGrid.ItemsSource = null;
            this.LoadProfessorFromDB();
        }

        private void UploadButton_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("是否确认上传当前Excel数据？", "上传新数据", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
            {
                new Task(() =>
                {
                    this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", 0, ImportProfessors.Count); }));
                    var badProfessors = "";
                    for (int i = 0; i < ImportProfessors.Count; i++)
                    {
                        if (ImportProfessors[i].Create())
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", i + 1, ImportProfessors.Count); }));
                        else
                            badProfessors += ImportProfessors[i].Name + " ";
                    }
                    if (badProfessors.Equals(""))
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传成功，共{0}条数据", ImportProfessors.Count); this.LoadProfessorFromDB(); }));
                    }
                    else
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("以下建筑上传失败 {0}", badProfessors); this.LoadProfessorFromDB(); }));
                    }
                }).Start();
            }
        }

        private void DownLoadButton_Click(object sender, RoutedEventArgs e)
        {
            Excel.Worksheet worksheet = ApplicationHelper.CreateWorkSheet();
            worksheet.Cells[1, 1] = "教师编号";
            worksheet.Cells[1, 2] = "姓名";
            var rowIndex = 2;
            foreach (var professor in Professor.GetAll(true))
            {
                worksheet.Cells[rowIndex, 1] = professor.ID;
                worksheet.Cells[rowIndex, 2] = professor.Name;
                rowIndex++;
            }
        }
    }
}
