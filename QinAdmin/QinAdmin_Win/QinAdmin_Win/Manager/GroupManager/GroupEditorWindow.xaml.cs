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
    /// GroupEditorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class GroupEditorWindow : Window
    {
        public Group EditingGroup;
        public GroupEditorWindow()
        {
            InitializeComponent();
        }

        private void ConfirmButton_Click(object sender, RoutedEventArgs e)
        {
            if (!this.GroupNameTextBox.Text.isEmptyOrNull() && !this.GroupIDTextBox.Text.isEmptyOrNull())
            {
                this.EditingGroup.ID = this.GroupIDTextBox.Text;
                this.EditingGroup.Name = this.GroupNameTextBox.Text;
                _ = this.EditingGroup.objectId.isEmptyOrNull() ? this.EditingGroup.Create() : this.EditingGroup.Update();
                this.Close();
            }
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.GroupNameTextBox.Text = EditingGroup.Name;
            this.GroupIDTextBox.Text = EditingGroup.ID;
        }
    }
}
