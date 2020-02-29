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

namespace QinAdmin_Win.ReManager.Re_Building_Room
{
    /// <summary>
    /// ReAdminWindows.xaml 的交互逻辑
    /// </summary>
    public partial class ReAdminWindows : Window
    {
        List<ReBuildingRoom> Relations;
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
            Relations = ReBuildingRoom.GetAll(true);
            this.RelationDataGrid.ItemsSource = this.Relations;
        }

        private void AddReButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var newReEditor = new ReEditorWindow();
                newReEditor.EditRelation = new ReBuildingRoom() { BuildingID = "", RoomID = "", objectId = null };
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
                if (this.RelationDataGrid.SelectedItem is ReBuildingRoom)
                {
                    var newReEditor = new ReEditorWindow();
                    newReEditor.EditRelation = this.RelationDataGrid.SelectedItem as ReBuildingRoom;
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
            if (this.RelationDataGrid.SelectedItem is ReBuildingRoom)
            {
                var deleteRe = this.RelationDataGrid.SelectedItem as ReBuildingRoom;
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
                var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "ReBuildingRoom.xlsx");
                if (DatabaseHelper.LCGetExcelFile("ReBuildingRoom", des))
                {
                    System.Diagnostics.Process.Start(openFileDlg.SelectedPath);
                }
                else
                {
                    MessageBox.Show("下载失败");
                }
            }
        }

        List<ReBuildingRoom> ImportReBuildingRooms = new List<ReBuildingRoom>();
        private void ImportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.OpenFileDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                new Task(() =>
                {
                    try
                    {
                        ImportReBuildingRooms = new List<ReBuildingRoom>();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在读取Excel文件"; }));
                        var workSheet = ApplicationHelper.GetWorkSheetByName(openFileDlg.FileName, "数据表格");
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            ImportReBuildingRooms.Add(ReBuildingRoom.CreateAndVertify(
                                BuildingID: workSheet.IsNullOrEmpty(i + 1, "建筑物编号", "建筑物编号错误")
                                , RoomID: workSheet.IsNullOrEmpty(i + 1, "房间编号", "房间编号错误")));
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        workSheet.CloseApplication();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("读取完毕，共 {0} 行", ImportReBuildingRooms.Count); this.RelationDataGrid.ItemsSource = ImportReBuildingRooms; }));
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
                    this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", 0, ImportReBuildingRooms.Count); }));
                    var badReBuildingRooms = "";
                    for (int i = 0; i < ImportReBuildingRooms.Count; i++)
                    {
                        if (ImportReBuildingRooms[i].Create())
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", i + 1, ImportReBuildingRooms.Count); }));
                        else
                            badReBuildingRooms += ImportReBuildingRooms[i].ToSearcheString() + " ";
                    }
                    if (badReBuildingRooms.Equals(""))
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传成功，共{0}条数据", ImportReBuildingRooms.Count); this.LoadRelationFromDB(); }));
                    }
                    else
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("以下上传失败 {0}", badReBuildingRooms); this.LoadRelationFromDB(); }));
                    }
                }).Start();
            }
        }

        private void DownLoadButton_Click(object sender, RoutedEventArgs e)
        {
            Excel.Worksheet worksheet = ApplicationHelper.CreateWorkSheet();
            worksheet.Cells[1, 1] = "建筑物编号";
            worksheet.Cells[1, 2] = "建筑名称";
            worksheet.Cells[1, 3] = "房间编号";
            worksheet.Cells[1, 4] = "房间名称";
            var rowIndex = 2;
            foreach (var reBuildingRoom in ReBuildingRoom.GetAll(true))
            {
                worksheet.Cells[rowIndex, 1] = reBuildingRoom.Building.ID;
                worksheet.Cells[rowIndex, 2] = reBuildingRoom.Building.Name;
                worksheet.Cells[rowIndex, 3] = reBuildingRoom.Room.ID;
                worksheet.Cells[rowIndex, 4] = reBuildingRoom.Room.Name;
                rowIndex++;
            }
        }
    }
}
