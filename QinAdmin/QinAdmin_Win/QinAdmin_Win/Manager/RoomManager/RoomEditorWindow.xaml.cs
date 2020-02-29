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

namespace QinAdmin_Win.RoomManager
{
    /// <summary>
    /// RoomEditorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class RoomEditorWindow : Window
    {
        public Room EditingRoom;
        public RoomEditorWindow()
        {
            InitializeComponent();
        }

        private void ConfirmButton_Click(object sender, RoutedEventArgs e)
        {
            if (!this.RoomNameTextBox.Text.isEmptyOrNull() && !this.RoomIDTextBox.Text.isEmptyOrNull() && !this.RoomBLETextBox.Text.isEmptyOrNull())
            {
                this.EditingRoom.ID = this.RoomIDTextBox.Text;
                this.EditingRoom.Name = this.RoomNameTextBox.Text;
                this.EditingRoom.BLE = int.Parse(this.RoomBLETextBox.Text);
                _ = this.EditingRoom.objectId == null ? this.EditingRoom.Create() : this.EditingRoom.Update();
                this.Close();
            }
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.RoomIDTextBox.Text = this.EditingRoom.ID;
            this.RoomBLETextBox.Text = this.EditingRoom.BLE.ToString();
            this.RoomNameTextBox.Text = this.EditingRoom.Name;
        }
    }
}
