using QinAdmin_Win.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace QinAdmin_Win.SectionManager
{
    /// <summary>
    /// SectionEditorWindow.xaml 的交互逻辑
    /// </summary>
    public partial class SectionEditorWindow : Window
    {
        public Section EditingSection;
        public ModelEditMode EditingMode;

        public bool IsSuccess = false;
        public SectionEditorWindow()
        {
            InitializeComponent();
        }

        private void ConfirmButton_Click(object sender, RoutedEventArgs e)
        {
            if (!this.SectionIDTextBox.Text.isEmptyOrNull() && !this.SectionNameTextBox.Text.isEmptyOrNull() && !this.SectionOrderTextBox.Text.isEmptyOrNull())
            {
                this.EditingSection.ID = this.SectionIDTextBox.Text;
                this.EditingSection.Name = this.SectionNameTextBox.Text;
                this.EditingSection.Order = int.Parse(this.SectionOrderTextBox.Text);
                this.EditingSection.StartTime = this.SectionStartTimePicker.Value.Value.ToString("HH:mm");
                this.EditingSection.EndTime = this.SectionEndTimePicker.Value.Value.ToString("HH:mm");
                _ = this.EditingSection.objectId == null ? this.EditingSection.Create() : this.EditingSection.Update();
                this.Close();
            }
        }

        private void Window_Loaded(object sender, EventArgs e)
        {
            this.SectionIDTextBox.Text = this.EditingSection.ID;
            this.SectionNameTextBox.Text = this.EditingSection.Name;
            this.SectionOrderTextBox.Text = this.EditingSection.Order.ToString();
            this.SectionStartTimePicker.Value = this.EditingSection.StartTime.ConvertToDateTime("HH:mm");
            this.SectionEndTimePicker.Value = this.EditingSection.EndTime.ConvertToDateTime("HH:mm");
        }
    }
}
