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
    /// LoginWIndow.xaml 的交互逻辑
    /// </summary>
    public partial class LoginWIndow : Window
    {
        public LoginWIndow()
        {
            InitializeComponent();
        }

        private void LoginButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.PasswordBoxPB.Password.Equals("01050305"))
            {
                var window = new MainWindow();
                Application.Current.MainWindow = window;
                this.Close();
                window.Show();
            }
        }
    }
}
