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

namespace QinAdmin_Win.ReManager.Re_Building_Room
{
    /// <summary>
    /// ReEditorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class ReEditorWindow : Window
    {
        public ReBuildingRoom EditRelation;
        public ReEditorWindow()
        {
            InitializeComponent();
        }

        private void ConfirmButton_Click(object sender, RoutedEventArgs e)
        {
            this.EditRelation.BuildingID = this.BuildingIDTextBox.Text;
            this.EditRelation.RoomID = this.RoomIDTextBox.Text;
            if (this.EditRelation.Building.objectId != null && this.EditRelation.Room.objectId != null)
            {
                _ = this.EditRelation.objectId.isEmptyOrNull() ? this.EditRelation.Create() : this.EditRelation.Update();
                this.Close();
            }
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.RoomIDTextBox.Text = EditRelation.RoomID;
            this.BuildingIDTextBox.Text = EditRelation.BuildingID;
        }
    }
}
