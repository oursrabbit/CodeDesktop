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

namespace QinAdmin_Win.ProfessorManager
{
    /// <summary>
    /// ProfessorEditorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class ProfessorEditorWindow : Window
    {
        public Professor EditingProfessor;
        public ProfessorEditorWindow()
        {
            InitializeComponent();
        }

        private void ConfirmButton_Click(object sender, RoutedEventArgs e)
        {
            if (!this.ProfessorNameTextBox.Text.isEmptyOrNull() && !this.SchoolIDTextBox.Text.isEmptyOrNull())
            {
                this.EditingProfessor.ID = this.SchoolIDTextBox.Text;
                this.EditingProfessor.Name = this.ProfessorNameTextBox.Text;
                _ = this.EditingProfessor.objectId == null ? this.EditingProfessor.Create() : this.EditingProfessor.Update();
                this.Close();
            }
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.SchoolIDTextBox.Text = this.EditingProfessor.ID;
            this.ProfessorNameTextBox.Text = this.EditingProfessor.Name;
        }
    }
}
