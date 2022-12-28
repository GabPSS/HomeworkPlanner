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
        public Task UpdatedTask { get; }
        public TaskHost TaskHost { get; set; }
        public TaskForm(TaskHost taskHost, Task displayingTask, bool addView = false)
        {
            InitializeComponent();
            SelectedTask = displayingTask;
            UpdatedTask = (Task)displayingTask.Clone();
            AddTaskMode = addView;
            TaskHost = taskHost;
            LoadTask();
        }

        public void LoadTask()
        {
            if (!AddTaskMode)
            {
                TaskBodyTextBox.Text = UpdatedTask.Name;
                DueDateTimePicker.Value = UpdatedTask.DueDate;
                DetailsMultilineTextBox.Lines = UpdatedTask.Description;
                ImportantCheckBox.Checked = UpdatedTask.IsImportant;
            }

            IDLabel.Text += UpdatedTask.TaskID == -1 ? (TaskHost.SaveFile.Tasks.LastIndex + 1) : UpdatedTask.TaskID;
            SubjectComboBox.Items.AddRange(TaskHost.SaveFile.Subjects.Items.ToArray());
            UpdateIcon();


            //Set selected subject
            if (UpdatedTask.SubjectID == -1)
            {
                SubjectComboBox.SelectedIndex = 1;
            }
            else
            {
                for (int i = 0; i < TaskHost.SaveFile.Subjects.Items.Count; i++)
                {
                    if (UpdatedTask.SubjectID == TaskHost.SaveFile.Subjects.Items[i].SubjectID)
                    {
                        SubjectComboBox.SelectedIndex = i + 2;

                    }
                }
            }
        }

        private void UpdateIcon()
        {
            TaskIconPictureBox.Image = UpdatedTask.GetIcon();
        }

        private void TaskBodyTextBox_TextChanged(object sender, EventArgs e)
        {
            UpdatedTask.Name = TaskBodyTextBox.Text;
        }

        private void DueDateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            UpdatedTask.DueDate = DueDateTimePicker.Value;
            UpdateIcon();
        }

        private void DetailsMultilineTextBox_TextChanged(object sender, EventArgs e)
        {
            UpdatedTask.Description = DetailsMultilineTextBox.Lines;
        }

        private void ImportantCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            UpdatedTask.IsImportant = ImportantCheckBox.Checked;
            UpdateIcon();
        }

        private void SubjectComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            Subject? subject = SubjectComboBox.SelectedItem as Subject;
            if (subject != null)
            {
                UpdatedTask.SubjectID = subject.SubjectID;
            }
            else
            {
                switch (SubjectComboBox.SelectedIndex)
                {
                    case 0:
                        //TODO: Implement adding subjects
                        throw new NotImplementedException();
                    case 1:
                        UpdatedTask.SubjectID = -1;
                        break;
                }
            }
        }
    }
}
