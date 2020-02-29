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

namespace QinAdmin_Win
{
    /// <summary>
    /// BuildingEditorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class BuildingEditorWindow : Window
    {
        public Building EditingBuilding;
        public BuildingEditorWindow()
        {
            InitializeComponent();
        }

        private void ConfirmButton_Click(object sender, RoutedEventArgs e)
        {
            if (!this.BuildingNameTextBox.Text.isEmptyOrNull() && !this.BuildingIDTextBox.Text.isEmptyOrNull())
            {
                this.EditingBuilding.ID = this.BuildingIDTextBox.Text;
                this.EditingBuilding.Name = this.BuildingNameTextBox.Text;
                _ = this.EditingBuilding.objectId.isEmptyOrNull() ? this.EditingBuilding.Create() : this.EditingBuilding.Update();
                this.Close();
            }
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.BuildingNameTextBox.Text = EditingBuilding.Name;
            this.BuildingIDTextBox.Text = EditingBuilding.ID;
        }
    }
}
