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

namespace QinAdmin_Win.StudentManager
{
    /// <summary>
    /// StudentEditorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class StudentEditorWindow : Window
    {
        public Student EditingStudent;
        public StudentEditorWindow()
        {
            InitializeComponent();
        }

        private void ConfirmButton_Click(object sender, RoutedEventArgs e)
        {
            if (!this.SchoolIDTextBox.Text.isEmptyOrNull() && !this.StudentNameTextBox.Text.isEmptyOrNull() && !this.BaiduFaceIDTextBox.Text.isEmptyOrNull() && !this.BLETextBox.Text.isEmptyOrNull())
            {
                this.EditingStudent.ID = this.SchoolIDTextBox.Text;
                this.EditingStudent.Name = this.StudentNameTextBox.Text;
                this.EditingStudent.BaiduFaceID = this.BaiduFaceIDTextBox.Text;
                this.EditingStudent.BLE = int.Parse(this.BLETextBox.Text);
                _ = this.EditingStudent.objectId == null ? this.EditingStudent.Create() : this.EditingStudent.Update();
                this.Close();
            }
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.SchoolIDTextBox.Text = this.EditingStudent.ID;
            this.StudentNameTextBox.Text = this.EditingStudent.Name;
            this.BaiduFaceIDTextBox.Text = this.EditingStudent.BaiduFaceID;
            this.BLETextBox.Text = this.EditingStudent.BLE.ToString();
        }
    }
}
