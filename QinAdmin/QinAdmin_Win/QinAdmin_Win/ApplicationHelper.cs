using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using Excel = Microsoft.Office.Interop.Excel;

namespace QinAdmin_Win
{

    public static class DateTimeExtension
    {
        public static bool IsInTimeSpan(this DateTime now, DateTime startTime, DateTime endTime)
        {
            if (DateTime.Compare(now, startTime) < 0)
            {
                return false;
            }
            if (DateTime.Compare(now, endTime) > 0)
            {
                return false;
            }
            return true;
        }
    }

    public static class StringExtension
    {
        public static string RemoveLast(this String value)
        {
            if (value.Length == 0)
            {
                return value;
            }
            else
            {
                return value.Remove(value.Length - 1);
            }
        }

        public static bool isEmptyOrNull(this String value)
        {
            return value == null || value.Replace(" ", "").Equals("");
        }

        public static DateTime? ConvertToDateTime(this string value, string format)
        {
            try
            {
                DateTime dt;
                DateTimeFormatInfo dtFormat = new DateTimeFormatInfo();
                dtFormat.ShortDatePattern = format;
                dt = Convert.ToDateTime(value, dtFormat);
                return dt;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return null;
            }
        }

        public static int? ConvertToInt(this string value)
        {
            try
            {
                return int.Parse(value);
            }
            catch
            {
                return null;
            }
        }
    }

    public static class ExcelWorkSheetExtension
    {
        public static string IsNullOrEmpty(this Excel.Worksheet workSheet, int row, string columnName, string errorMessage)
        {
            var column = -1;
            for (int i = 0; i < workSheet.UsedRange.Columns.Count; i++)
            {
                string columnString = Convert.ToString(((Excel.Range)workSheet.Cells[1, i + 1]).Value2);
                if (columnName.Equals(columnString))
                {
                    column = i + 1;
                    break;
                }
            }
            if (column == -1)
            {
                workSheet.CloseApplication();
                MessageBox.Show(String.Format("未找到列 {0}", columnName), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                throw new Exception(String.Format("未找到列 {0}", columnName));
            }

            string value = Convert.ToString(((Excel.Range)workSheet.Cells[row, column]).Value2);

            if (value.isEmptyOrNull())
            {
                workSheet.CloseApplication();
                MessageBox.Show(String.Format("{0}\n\n第{1}行，第{2}列", errorMessage, row, column), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                throw new Exception(String.Format("{0}\n\n第{1}行，第{2}列", errorMessage, row, column));
            }
            return value;
        }

        public static int IsNumber(this Excel.Worksheet workSheet, int row, string columnName, string errorMessage)
        {
            var column = -1;
            for (int i = 0; i < workSheet.UsedRange.Columns.Count; i++)
            {
                string columnString = Convert.ToString(((Excel.Range)workSheet.Cells[1, i + 1]).Value2);
                if (columnName.Equals(columnString))
                {
                    column = i + 1;
                    break;
                }
            }
            if (column == -1)
            {
                workSheet.CloseApplication();
                MessageBox.Show(String.Format("未找到列 {0}", columnName), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                throw new Exception(String.Format("未找到列 {0}", columnName));
            }

            string value = Convert.ToString(((Excel.Range)workSheet.Cells[row, column]).Value2);
            var numberValue = 0;
            if (int.TryParse(value, out numberValue) == false)
            {
                workSheet.CloseApplication();
                MessageBox.Show(String.Format("{0}\n\n第{1}行，第{2}列", errorMessage, row, column), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                throw new Exception(String.Format("{0}\n\n第{1}行，第{2}列", errorMessage, row, column));
            }

            return numberValue;
        }

        public static DateTime isTime(this Excel.Worksheet workSheet, int row, string columnName, string errorMessage)
        {
            var column = -1;
            for (int i = 0; i < workSheet.UsedRange.Columns.Count; i++)
            {
                string columnString = Convert.ToString(((Excel.Range)workSheet.Cells[1, i + 1]).Value2);
                if (columnName.Equals(columnString))
                {
                    column = i + 1;
                    break;
                }
            }
            if (column == -1)
            {
                workSheet.CloseApplication();
                MessageBox.Show(String.Format("未找到列 {0}", columnName), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                throw new Exception(String.Format("未找到列 {0}", columnName));
            }

            string value = Convert.ToString(((Excel.Range)workSheet.Cells[row, column]).Value2);
            var timeValue = value.ConvertToDateTime("HH:mm");
            if (timeValue == null)
            {
                workSheet.CloseApplication();
                MessageBox.Show(String.Format("{0}\n\n第{1}行，第{2}列", errorMessage, row, column), "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                throw new Exception(String.Format("{0}\n\n第{1}行，第{2}列", errorMessage, row, column));
            }

            return timeValue.Value;
        }

        public static void CloseApplication(this Excel.Worksheet worksheet)
        {
            worksheet.Application.CloseApplication();
        }
    }

    public static class ExcelApplicationExtension
    {
        public static void CloseApplication(this Excel.Application excelApplication)
        {
            for (int i = 0; i < excelApplication.Workbooks.Count; i++)
            {
                Excel.Workbook workbook = excelApplication.Workbooks[i + 1];
                for (int j = 0; j < workbook.Worksheets.Count; j++)
                {
                    Excel.Worksheet worksheet = workbook.Worksheets[j + 1];
                    releaseObject(worksheet);
                }
                workbook.Close(0);
                releaseObject(workbook);
            }
            excelApplication.Quit();
            releaseObject(excelApplication);
        }
        private static void releaseObject(object obj)
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
    }

    public static class ApplicationHelper
    {
        public static Excel.Worksheet GetWorkSheetByIndex(string filePath, int sheetIndex)
        {
            try
            {
                var excelApplication = new Excel.Application();
                excelApplication.Visible = false;
                var workBook = excelApplication.Workbooks.Open(filePath, ReadOnly: true);
                return (Excel.Worksheet)workBook.Worksheets[sheetIndex];
            }
            catch
            {
                throw new Exception("获取WorkSheet失败，索引错误");
            }
        }
        public static Excel.Worksheet GetWorkSheetByName(string filePath, string sheetName)
        {
            try
            {
                var excelApplication = new Excel.Application();
                excelApplication.Visible = false;
                var workBook = excelApplication.Workbooks.Open(filePath, ReadOnly: true);
                for (int i = 0; i < workBook.Worksheets.Count; i++)
                {
                    Excel.Worksheet worksheet = workBook.Worksheets[i + 1];
                    if (worksheet.Name.Contains(sheetName))
                    {
                        return worksheet;
                    }
                }
                throw new Exception("获取WorkSheet失败，名称错误");
            }
            catch
            {
                throw new Exception("获取WorkSheet失败，名称错误");
            }
        }

        public static Excel.Worksheet CreateWorkSheet()
        {
            var excelApplication = new Excel.Application();
            excelApplication.Visible = true;
            Excel.Workbook workBook = excelApplication.Workbooks.Add(System.Reflection.Missing.Value);
            return (Excel.Worksheet)workBook.Sheets[1];
        }
    }
}
