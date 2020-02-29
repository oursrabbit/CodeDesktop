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

namespace QinAdmin_Win.ReManager.Re_Student_Group
{
    /// <summary>
    /// ReEditorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class ReEditorWindow : Window
    {
        public ReStudentGroup EditRelation;
        public ReEditorWindow()
        {
            InitializeComponent();
        }

        private void ConfirmButton_Click(object sender, RoutedEventArgs e)
        {
            this.EditRelation.StudentID = this.StudentIDTextBox.Text;
            this.EditRelation.GroupID = this.GroupIDTextBox.Text;
            if (this.EditRelation.Student.objectId != null && this.EditRelation.Group.objectId != null)
            {
                _ = this.EditRelation.objectId.isEmptyOrNull() ? this.EditRelation.Create() : this.EditRelation.Update();
                this.Close();
            }
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.GroupIDTextBox.Text = EditRelation.GroupID;
            this.StudentIDTextBox.Text = EditRelation.StudentID;
        }
    }
}
