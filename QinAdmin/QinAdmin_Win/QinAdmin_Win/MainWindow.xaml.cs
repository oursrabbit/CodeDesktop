using QinAdmin_Win.CourseManager;
using QinAdmin_Win.GroupManager;
using QinAdmin_Win.Manager.CheckRecordingManager;
using QinAdmin_Win.ProfessorManager;
using QinAdmin_Win.RoomManager;
using QinAdmin_Win.SectionManager;
using QinAdmin_Win.StudentManager;
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
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace QinAdmin_Win
{
    /// <summary>
    /// MainWindow.xaml 的交互逻辑
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void AdminBuildingButton_Click(object sender, RoutedEventArgs e)
        {
            (new AdminBuildingWindow()).Show();
        }

        private void AdminRoomButton_Click(object sender, RoutedEventArgs e)
        {
            (new AdminRoomWindow()).Show();
        }

        private void AdminStudentButton_Click(object sender, RoutedEventArgs e)
        {
            (new AdminStudentWindow()).Show();
        }

        private void AdminGroupButton_Click(object sender, RoutedEventArgs e)
        {
            (new AdminGroupWindow()).Show();
        }

        private void AdminSectionButton_Click(object sender, RoutedEventArgs e)
        {
            (new AdminSectionWindow()).Show();
        }

        private void AdminProfessorButton_Click(object sender, RoutedEventArgs e)
        {
            (new AdminProfessorWindow()).Show();
        }

        private void AdminCourseButton_Click(object sender, RoutedEventArgs e)
        {
            (new AdminCourseWindow()).Show();
        }

        private void AdminScheduleButton_Click(object sender, RoutedEventArgs e)
        {
            (new ReManager.Re_Schedule.ReAdminWindows()).Show();
        }

        private void AdminReBuildingRoomButton_Click(object sender, RoutedEventArgs e)
        {
            (new ReManager.Re_Building_Room.ReAdminWindows()).Show();
        }

        private void AdminReStudentGroup_Click(object sender, RoutedEventArgs e)
        {
            (new ReManager.Re_Student_Group.ReAdminWindows()).Show();
        }

        private void AdminCheckRecording_Click(object sender, RoutedEventArgs e)
        {
            (new AdminCheckRecordingWindow()).Show();
        }
    }
}
