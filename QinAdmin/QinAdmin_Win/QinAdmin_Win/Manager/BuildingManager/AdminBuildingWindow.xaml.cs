using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Excel = Microsoft.Office.Interop.Excel;
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
using System.Runtime.InteropServices;

namespace QinAdmin_Win
{
    /// <summary>
    /// AdminBuildingWindow.xaml 的交互逻辑
    /// </summary>
    public partial class AdminBuildingWindow : Window
    {
        List<Building> Buildings;
        public AdminBuildingWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.LoadBuildingFromDB();
        }

        private void LoadBuildingFromDB()
        {
            Buildings = Building.GetAll(true);
            this.BuildingDataGrid.ItemsSource = this.Buildings;
        }

        private void AddBuildingButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var newBuildingEditor = new BuildingEditorWindow();
                newBuildingEditor.EditingBuilding = new Building() { ID = "", Name = "", objectId = null };
                newBuildingEditor.ShowDialog();
                this.LoadBuildingFromDB();
            }
            catch
            {
                MessageBox.Show("添加失败");
            }
        }

        private void EditBuildingButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var newBuildingEditor = new BuildingEditorWindow();
                newBuildingEditor.EditingBuilding = this.BuildingDataGrid.SelectedItem as Building ?? new Building() { ID = "", Name = "", objectId = null };
                newBuildingEditor.ShowDialog();
                this.LoadBuildingFromDB();
            }
            catch
            {
                MessageBox.Show("更新失败");
            }
        }

        private void DeleteBuildingButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.BuildingDataGrid.SelectedItem != null)
            {
                var deleteBuilding = this.BuildingDataGrid.SelectedItem as Building;
                if (MessageBox.Show(String.Format("确定删除？ {0}", deleteBuilding.ToSearcheString()), "删除", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    if (deleteBuilding.Delete())
                    {
                        this.LoadBuildingFromDB();
                    }
                    else
                    {
                        MessageBox.Show("删除失败: {0}", deleteBuilding.ToSearcheString());
                    }
                }
            }
        }

        private void FilterButton_Click(object sender, RoutedEventArgs e)
        {
            this.BuildingDataGrid.ItemsSource = null;
            this.BuildingDataGrid.ItemsSource = this.Buildings.Where(t => t.ToSearcheString().Contains(this.KeywordTextBox.Text));
        }

        private void ExportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.FolderBrowserDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "Building.xlsx");
                if (DatabaseHelper.LCGetExcelFile("Building", des))
                {
                    System.Diagnostics.Process.Start(openFileDlg.SelectedPath);
                }
                else
                {
                    MessageBox.Show("下载失败");
                }
            }
        }

        List<Building> ImportBuildings = new List<Building>();
        private void ImportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.OpenFileDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                new Task(() =>
                {
                    try
                    {
                        ImportBuildings = new List<Building>();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在读取Excel文件"; }));
                        var workSheet = ApplicationHelper.GetWorkSheetByName(openFileDlg.FileName, "数据表格");
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            ImportBuildings.Add(new Building() { 
                                ID = workSheet.IsNullOrEmpty(i + 1, "建筑物编号", "建筑物编号错误"),
                                Name = workSheet.IsNullOrEmpty(i + 1, "建筑名称", "建筑名称错误")
                            });
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        workSheet.CloseApplication();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("读取完毕，共 {0} 行", ImportBuildings.Count); this.BuildingDataGrid.ItemsSource = ImportBuildings; }));
                    }
                    catch(Exception ex)
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传失败：{0}", ex.ToString()); }));
                    }
                }).Start();
            }
        }



        private void ReloadButton_Click(object sender, RoutedEventArgs e)
        {
            this.BuildingDataGrid.ItemsSource = null;
            this.LoadBuildingFromDB();
        }

        private void UploadButton_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("是否确认上传当前Excel数据？", "上传新数据", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
            {
                new Task(() =>
                {
                    this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", 0, ImportBuildings.Count); }));
                    var badBuildings = "";
                    for (int i = 0; i < ImportBuildings.Count; i++)
                    {
                        if (ImportBuildings[i].Create())
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", i + 1, ImportBuildings.Count); }));
                        else
                            badBuildings += ImportBuildings[i].Name + " ";
                    }
                    if (badBuildings.Equals(""))
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传成功，共{0}条数据", ImportBuildings.Count); this.LoadBuildingFromDB(); }));
                    }
                    else
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("以下建筑上传失败 {0}", badBuildings); this.LoadBuildingFromDB(); }));
                    }
                }).Start();
            }
        }

        private void DownLoadButton_Click(object sender, RoutedEventArgs e)
        {
            Excel.Worksheet worksheet = ApplicationHelper.CreateWorkSheet();
            worksheet.Cells[1, 1] = "建筑物编号";
            worksheet.Cells[1, 2] = "建筑名称";
            var rowIndex = 2;
            foreach (var building in Building.GetAll(true))
            {
                worksheet.Cells[rowIndex, 1] = building.ID;
                worksheet.Cells[rowIndex, 2] = building.Name;
                rowIndex++;
            }
        }
    }
}
