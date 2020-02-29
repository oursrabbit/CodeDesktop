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

namespace QinAdmin_Win.SectionManager
{
    /// <summary>
    /// AdminSectionWindow.xaml 的交互逻辑
    /// </summary>
    public partial class AdminSectionWindow : Window
    {
        List<Section> Sections;
        public AdminSectionWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.LoadSectionFromDB();
        }

        private void LoadSectionFromDB()
        {
            Sections = Section.GetAll(true);
            this.SectionDataGrid.ItemsSource = this.Sections;
        }

        private void AddSectionButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var newSectionEditor = new SectionEditorWindow();
                newSectionEditor.EditingSection = new Section() { ID = "", Name = "", StartTime = "", EndTime = "", Order = -1, objectId = null };
                newSectionEditor.ShowDialog();
                this.LoadSectionFromDB();
            }
            catch
            {
                MessageBox.Show("添加失败");
            }
        }

        private void EditSectionButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.SectionDataGrid.SelectedItem != null)
            {
                try
                {
                    var editSection = this.SectionDataGrid.SelectedItem as Section;
                    var newSectionEditor = new SectionEditorWindow();
                    newSectionEditor.EditingSection = editSection;
                    newSectionEditor.Show();
                    this.LoadSectionFromDB();
                }
                catch
                {
                    MessageBox.Show("修改失败");
                }
            }
        }

        private void DeleteSectionButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.SectionDataGrid.SelectedItem != null)
            {
                var deleteSection = this.SectionDataGrid.SelectedItem as Section;
                if (MessageBox.Show(String.Format("确定删除？ {0}", deleteSection.ToSearcheString()), "删除", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    if (deleteSection.Delete())
                    {
                        this.LoadSectionFromDB();
                    }
                    else
                    {
                        MessageBox.Show("删除失败: {0}", deleteSection.ToSearcheString());
                    }
                }
            }
        }

        private void FilterButton_Click(object sender, RoutedEventArgs e)
        {
            this.SectionDataGrid.ItemsSource = null;
            this.SectionDataGrid.ItemsSource = this.Sections.Where(t => t.ToSearcheString().Contains(this.KeywordTextBox.Text));
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
                        if (!DatabaseHelper.LCGetExcelFile("Section", @"Section.xlsx"))
                        {
                            MessageBox.Show("下载失败");
                        }
                        var des = System.IO.Path.Combine(openFileDlg.SelectedPath, "Section.xlsx");
                        System.IO.File.Copy("Section.xlsx", des, true);
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

        List<Section> ImportSections = new List<Section>();
        private void ImportExcelTemplateButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDlg = new System.Windows.Forms.OpenFileDialog();
            if (openFileDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                new Task(() =>
                {
                    try
                    {
                        ImportSections = new List<Section>();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = "正在读取Excel文件"; }));
                        var workSheet = ApplicationHelper.GetWorkSheetByName(openFileDlg.FileName, "数据表格");
                        for (int i = 1; i < workSheet.UsedRange.Rows.Count; i++)
                        {
                            ImportSections.Add(new Section()
                            {
                                ID = workSheet.IsNullOrEmpty(i + 1, "学时编号", "学时编号错误"),
                                Name = workSheet.IsNullOrEmpty(i + 1, "学时名称", "学时名称错误"),
                                Order = workSheet.IsNumber(i + 1, "学时顺序", "学时顺序错误"),
                                StartTime = workSheet.isTime(i + 1, "起始时间", "起始时间错误").ToString("HH:mm"),
                                EndTime = workSheet.isTime(i + 1, "结束时间", "结束时间错误").ToString("HH:mm")
                            }); ;
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在读取Excel文件 第{0}行", i + 1); }));
                        }
                        workSheet.CloseApplication();
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("读取完毕，共 {0} 行", ImportSections.Count); this.SectionDataGrid.ItemsSource = ImportSections; }));
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
            this.SectionDataGrid.ItemsSource = null;
            this.LoadSectionFromDB();
        }

        private void UploadButton_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("是否确认上传当前Excel数据？", "上传新数据", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
            {
                new Task(() =>
                {
                    this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", 0, ImportSections.Count); }));
                    var badSections = "";
                    for (int i = 0; i < ImportSections.Count; i++)
                    {
                        if (ImportSections[i].Create())
                            this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("正在上传数据 {0}/{1}", i + 1, ImportSections.Count); }));
                        else
                            badSections += ImportSections[i].Name + " ";
                    }
                    if (badSections.Equals(""))
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("上传成功，共{0}条数据", ImportSections.Count); this.LoadSectionFromDB(); }));
                    }
                    else
                    {
                        this.InfoLabel.Dispatcher.BeginInvoke(new Action(() => { this.InfoLabel.Content = String.Format("以下建筑上传失败 {0}", badSections); this.LoadSectionFromDB(); }));
                    }
                }).Start();
            }
        }

        private void DownLoadButton_Click(object sender, RoutedEventArgs e)
        {
            Excel.Worksheet worksheet = ApplicationHelper.CreateWorkSheet();
            worksheet.Cells[1, 1] = "学时编号";
            worksheet.Cells[1, 2] = "学时名称";
            worksheet.Cells[1, 3] = "学时顺序";
            worksheet.Cells[1, 4] = "起始时间";
            worksheet.Cells[1, 5] = "结束时间";
            var rowIndex = 2;
            foreach (var section in Section.GetAll(true))
            {
                worksheet.Cells[rowIndex, 1] = section.ID;
                worksheet.Cells[rowIndex, 2] = section.Name;
                worksheet.Cells[rowIndex, 3] = section.Order;
                worksheet.Cells[rowIndex, 4] = section.StartTime;
                worksheet.Cells[rowIndex, 5] = section.EndTime;
                rowIndex++;
            }
        }
    }
}
