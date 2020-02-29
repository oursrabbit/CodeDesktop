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

namespace QinAdmin_Win.GroupManager
{
    /// <summary>
    /// AdminGroupWindow.xaml 的交互逻辑
    /// </summary>
    public partial class AdminGroupWindow : Window
    {
        List<Group> Groups;
        public AdminGroupWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.LoadGroupFromDB();
        }

        private void LoadGroupFromDB()
        {
            Groups = Group.GetAll(true);
            this.GroupDataGrid.ItemsSource = this.Groups;
        }

        private void AddGroupButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var newGroupEditor = new GroupEditorWindow();
            newGroupEditor.EditingGroup = new Group() {ID="", Name ="", objectId=null };
                newGroupEditor.ShowDialog(); this.LoadGroupFromDB();
                }
            catch
            {
                MessageBox.Show("添加失败");
            }
        }

        private void EditGroupButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.GroupDataGrid.SelectedItem != null)
            {
                try
                {
                    var editGroup = this.GroupDataGrid.SelectedItem as Group;
                    var newGroupEditor = new GroupEditorWindow();
                    newGroupEditor.EditingGroup = editGroup;
                    newGroupEditor.ShowDialog();
                    this.LoadGroupFromDB();
                }
                catch
                {
                    MessageBox.Show("更新失败");
                }
            }
        }

        private void DeleteGroupButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.GroupDataGrid.SelectedItem != null)
            {
                var deleteGroup = this.GroupDataGrid.SelectedItem as Group;
                if (MessageBox.Show(String.Format("确定删除？ {0}", deleteGroup.ToSearcheString()), "删除", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    if (deleteGroup.Delete())
                    {
                        this.LoadGroupFromDB();
                    }
                    else
                    {
                        MessageBox.Show("删除失败: {0}", deleteGroup.ToSearcheString());
                    }
                }
            }
        }

        private void FilterButton_Click(object sender, RoutedEventArgs e)
        {
            this.GroupDataGrid.ItemsSource = null;
            this.GroupDataGrid.ItemsSource = this.Groups.Where(t => t.ToSearcheString().Contains(this.KeywordTextBox.Text));
        }

        private void ExportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.FolderBrowserDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "Group.xlsx");
                if (DatabaseHelper.LCGetExcelFile("Group", des))
                {
                    System.Diagnostics.Process.Start(openFileDlg.SelectedPath);
                }
                else
                {
                    MessageBox.Show("下载失败");
                }
            }
        }

        List<Group> ImportGroups = new List<Group>();
        private void ImportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.OpenFileDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                new Task(() =>
                {
                    try
                    {
                        ImportGroups = new List<Group>();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在读取Excel文件"; }));
                        var workSheet = ApplicationHelper.GetWorkSheetByName(openFileDlg.FileName, "数据表格");
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            ImportGroups.Add(new Group()
                            {
                                ID = workSheet.IsNullOrEmpty(i + 1, "班级编号", "班级编号错误"),
                                Name = workSheet.IsNullOrEmpty(i + 1, "班级名称", "班级名称错误")
                            });
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        workSheet.CloseApplication();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("读取完毕，共 {0} 行", ImportGroups.Count); this.GroupDataGrid.ItemsSource = ImportGroups; }));
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
            this.GroupDataGrid.ItemsSource = null;
            this.LoadGroupFromDB();
        }

        private void UploadButton_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("是否确认上传当前Excel数据？", "上传新数据", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
            {
                new Task(() =>
                {
                    this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", 0, ImportGroups.Count); }));
                    var badGroups = "";
                    for (int i = 0; i < ImportGroups.Count; i++)
                    {
                        if (ImportGroups[i].Create())
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", i + 1, ImportGroups.Count); }));
                        else
                            badGroups += ImportGroups[i].Name + " ";
                    }
                    if (badGroups.Equals(""))
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传成功，共{0}条数据", ImportGroups.Count); this.LoadGroupFromDB(); }));
                    }
                    else
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("以下建筑上传失败 {0}", badGroups); this.LoadGroupFromDB(); }));
                    }
                }).Start();
            }
        }

        private void DownLoadButton_Click(object sender, RoutedEventArgs e)
        {
            Excel.Worksheet worksheet = ApplicationHelper.CreateWorkSheet();
            worksheet.Cells[1, 1] = "班级编号";
            worksheet.Cells[1, 2] = "班级名称";
            var rowIndex = 2;
            foreach (var group in Group.GetAll(true))
            {
                worksheet.Cells[rowIndex, 1] = group.ID;
                worksheet.Cells[rowIndex, 2] = group.Name;
                rowIndex++;
            }
        }
    }
}
