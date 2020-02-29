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

namespace QinAdmin_Win.CourseManager
{
    /// <summary>
    /// CourseEditorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class CourseEditorWindow : Window
    {
        public Course EditingCourse;
        public CourseEditorWindow()
        {
            InitializeComponent();
        }

        private void ConfirmButton_Click(object sender, RoutedEventArgs e)
        {
            if (!this.CourseNameTextBox.Text.isEmptyOrNull() && !this.CourseIDTextBox.Text.isEmptyOrNull())
            {
                this.EditingCourse.ID = this.CourseIDTextBox.Text;
                this.EditingCourse.Name = this.CourseNameTextBox.Text;
                _ = this.EditingCourse.objectId.isEmptyOrNull() ? this.EditingCourse.Create() : this.EditingCourse.Update();
                this.Close();
            }
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.CourseNameTextBox.Text = EditingCourse.Name;
            this.CourseIDTextBox.Text = EditingCourse.ID;
        }
    }
}
