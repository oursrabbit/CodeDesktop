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

namespace QinAdmin_Win.ReManager.Re_Schedule
{
    /// <summary>
    /// ReEditorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class ReEditorWindow : Window
    {
        public Schedule EditRelation;
        public ReEditorWindow()
        {
            InitializeComponent();
        }

        private void ConfirmButton_Click(object sender, RoutedEventArgs e)
        {
            if (!this.ScheduleIDTextBox.Text.isEmptyOrNull() || !this.RoomIDTextBox.Text.isEmptyOrNull() || !this.StartSectionIDTextBox.Text.isEmptyOrNull() || !this.ContinueSectionTextBox.Text.isEmptyOrNull() || !this.ContinueWeekTextBox.Text.isEmptyOrNull() || !this.CourseIDTextBox.Text.isEmptyOrNull())
            {
                this.EditRelation.ID = this.StartSectionIDTextBox.Text;
                this.EditRelation.RoomID = this.RoomIDTextBox.Text;
                this.EditRelation.StartSectionID = this.StartSectionIDTextBox.Text;
                this.EditRelation.ContinueSection = int.Parse(this.ContinueSectionTextBox.Text);
                this.EditRelation.StartDate = this.StartDatePicker.SelectedDate.Value.ToString("yyyy-MM-dd");
                this.EditRelation.ContinueWeek = int.Parse(this.ContinueWeekTextBox.Text);
                this.EditRelation.CourseID = this.CourseIDTextBox.Text;
                _ = this.EditRelation.objectId.isEmptyOrNull() ? this.EditRelation.Create() : this.EditRelation.Update();
                this.Close();
            }
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.ScheduleIDTextBox.Text = this.EditRelation.ID;
            this.RoomIDTextBox.Text = this.EditRelation.RoomID;
            this.StartSectionIDTextBox.Text = this.EditRelation.StartSectionID;
            this.ContinueSectionTextBox.Text = this.EditRelation.ContinueSection.ToString();
            this.StartDatePicker.SelectedDate = this.EditRelation.StartDate.ConvertToDateTime("yyyy-MM-dd");
            this.ContinueWeekTextBox.Text = this.EditRelation.ContinueWeek.ToString();
            this.CourseIDTextBox.Text = this.EditRelation.CourseID.ToString();
        }
    }
}
