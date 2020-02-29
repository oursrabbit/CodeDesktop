using Newtonsoft.Json.Linq;
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

namespace QinAdmin_Win.RoomManager
{
    /// <summary>
    /// AdminRoomWindow.xaml 的交互逻辑
    /// </summary>
    public partial class AdminRoomWindow : Window
    {
        List<Room> Rooms;
        public AdminRoomWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.LoadRoomFromDB();
        }

        private void LoadRoomFromDB()
        {
            Rooms = Room.GetAll(true);
            this.RoomDataGrid.ItemsSource = this.Rooms;
        }

        private void AddRoomButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var newRoomEditor = new RoomEditorWindow();
                newRoomEditor.EditingRoom = new Room() { ID = "", Name = "", BLE = -1, objectId = null };
                newRoomEditor.ShowDialog();
                this.LoadRoomFromDB();
            }
            catch
            {
                MessageBox.Show("添加失败");
            }
        }

        private void EditRoomButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.RoomDataGrid.SelectedItem != null)
            {
                try
                {
                    var editRoom = this.RoomDataGrid.SelectedItem as Room;
                    var newRoomEditor = new RoomEditorWindow();
                    newRoomEditor.EditingRoom = editRoom;
                    newRoomEditor.ShowDialog();
                    this.LoadRoomFromDB();
                }
                catch
                {
                    MessageBox.Show("修改失败");
                }
            }
        }

        private void DeleteRoomButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.RoomDataGrid.SelectedItem != null)
            {
                var deleteRoom = this.RoomDataGrid.SelectedItem as Room;
                if (MessageBox.Show(String.Format("确定删除？ {0}", deleteRoom.ToSearcheString()), "删除", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    if (deleteRoom.Delete())
                    {
                        this.LoadRoomFromDB();
                    }
                    else
                    {
                        MessageBox.Show("删除失败: {0}", deleteRoom.ToSearcheString());
                    }
                }
            }
        }

        private void FilterButton_Click(object sender, RoutedEventArgs e)
        {
            this.RoomDataGrid.ItemsSource = null;
            this.RoomDataGrid.ItemsSource = this.Rooms.Where(t => t.ToSearcheString().Contains(this.KeywordTextBox.Text));
        }

        private void ExportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.FolderBrowserDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "Room.xlsx");
                if (DatabaseHelper.LCGetExcelFile("Room", des))
                {
                    System.Diagnostics.Process.Start(openFileDlg.SelectedPath);
                }
                else
                {
                    MessageBox.Show("下载失败");
                }
            }
        }

        List<Room> ImportRooms = new List<Room>();
        private void ImportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.OpenFileDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                new Task(() =>
                {
                    try
                    {
                        ImportRooms = new List<Room>();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在读取Excel文件"; }));
                        var workSheet = ApplicationHelper.GetWorkSheetByName(openFileDlg.FileName, "数据表格");
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            ImportRooms.Add(new Room()
                            {
                                ID = workSheet.IsNullOrEmpty(i + 1, "房间编号", "房间编号错误"),
                                Name = workSheet.IsNullOrEmpty(i + 1, "房间名称", "房间名称错误"),
                                BLE = workSheet.IsNumber(i+1, "房间签到码", "房间签到码错误")
                            }); 
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        workSheet.CloseApplication();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("读取完毕，共 {0} 行", ImportRooms.Count); this.RoomDataGrid.ItemsSource = ImportRooms; }));
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
            this.RoomDataGrid.ItemsSource = null;
            this.LoadRoomFromDB();
        }

        private void UploadButton_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("是否确认上传当前Excel数据？", "上传新数据", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
            {
                new Task(() =>
                {
                    this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", 0, ImportRooms.Count); }));
                    var badRooms = "";
                    for (int i = 0; i < ImportRooms.Count; i++)
                    {
                        if (ImportRooms[i].Create())
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", i + 1, ImportRooms.Count); }));
                        else
                            badRooms += ImportRooms[i].Name + " ";
                    }
                    if (badRooms.Equals(""))
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传成功，共{0}条数据", ImportRooms.Count); this.LoadRoomFromDB(); }));
                    }
                    else
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("以下建筑上传失败 {0}", badRooms); this.LoadRoomFromDB(); }));
                    }
                }).Start();
            }
        }

        private void DownLoadButton_Click(object sender, RoutedEventArgs e)
        {
            Excel.Worksheet worksheet = ApplicationHelper.CreateWorkSheet();
            worksheet.Cells[1, 1] = "房间编号";
            worksheet.Cells[1, 2] = "房间名称";
            worksheet.Cells[1, 3] = "房间签到码";
            var rowIndex = 2;
            foreach (var room in Room.GetAll(true))
            {
                worksheet.Cells[rowIndex, 1] = room.ID;
                worksheet.Cells[rowIndex, 2] = room.Name;
                worksheet.Cells[rowIndex, 3] = room.BLE;
                rowIndex++;
            }
        }
    }
}
