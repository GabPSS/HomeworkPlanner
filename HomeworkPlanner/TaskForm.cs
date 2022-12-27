using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace HomeworkPlanner
{
    public partial class TaskForm : Form
    {
        public bool AddTaskMode { get; set; }
        public Task SelectedTask { get; }
        public Task ModifiedTask { get; }
        public TaskHost TaskHost { get; set; }
        public TaskForm(TaskHost taskHost, Task displayingTask, bool addView = false)
        {
            InitializeComponent();
            SelectedTask = displayingTask;
            ModifiedTask = (Task)displayingTask.Clone();
            AddTaskMode = addView;
            TaskHost = taskHost;
            if (addView)
            {
                SelectedTask = new Task();
            }
            LoadTask();
        }

        public void LoadTask()
        {
            TaskBodyTextBox.Text = ModifiedTask.Name;
            DueDateTimePicker.Value = ModifiedTask.DueDate;
            DetailsMultilineTextBox.Lines = ModifiedTask.Description;
            ImportantCheckBox.Checked = ModifiedTask.IsImportant;
            IDLabel.Text += ModifiedTask.TaskID == -1 ? (TaskHost.SaveFile.Tasks.LastIndex + 1) : ModifiedTask.TaskID;
            SubjectComboBox.Items.AddRange(TaskHost.SaveFile.Subjects.Items.ToArray());
            UpdateIcon();


            //Set selected subject
            if (ModifiedTask.SubjectID == -1)
            {
                SubjectComboBox.SelectedIndex = 1;
            }
            else
            {
                for (int i = 0; i < TaskHost.SaveFile.Subjects.Items.Count; i++)
                {
                    if (ModifiedTask.SubjectID == TaskHost.SaveFile.Subjects.Items[i].SubjectID)
                    {
                        SubjectComboBox.SelectedIndex = i + 2;

                    }
                }
            }
        }

        private void UpdateIcon()
        {
            TaskIconPictureBox.Image = ModifiedTask.GetIcon();
        }

        private void TaskBodyTextBox_TextChanged(object sender, EventArgs e)
        {
            ModifiedTask.Name = TaskBodyTextBox.Text;
        }

        private void DueDateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            ModifiedTask.DueDate = DueDateTimePicker.Value;
            UpdateIcon();
        }

        private void DetailsMultilineTextBox_TextChanged(object sender, EventArgs e)
        {
            ModifiedTask.Description = DetailsMultilineTextBox.Lines;
        }

        private void ImportantCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            ModifiedTask.IsImportant = ImportantCheckBox.Checked;
            UpdateIcon();
        }
    }
}
