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
        #region Properties, variables and constructor
        public bool AddTaskMode { get; set; }
        public Task SelectedTask { get; }
        public Task UpdatedTask { get; }
        public TaskHost TaskHost { get; set; }
        private int SubjectComboBoxSelectionIndex = 0;
        public TaskForm(TaskHost taskHost, Task displayingTask, bool addView = false)
        {
            InitializeComponent();
            SelectedTask = displayingTask;
            UpdatedTask = (Task)displayingTask.Clone();
            AddTaskMode = addView;
            TaskHost = taskHost;
            LoadTask();
        }
        #endregion
        #region Task and subject loading
        public void LoadTask()
        {
            if (!AddTaskMode)
            {
                TaskBodyTextBox.Text = UpdatedTask.Name == Task.UntitledTaskText ? "" : UpdatedTask.Name;
                if (UpdatedTask.DueDate == DateTime.MinValue)
                {
                    DueDateTimePicker.Checked = false;
                    DueDateTimePicker.Value = DateTime.Today.AddDays(1);
                }
                else
                {
                    DueDateTimePicker.Value = UpdatedTask.DueDate;
                }
                DetailsMultilineTextBox.Lines = UpdatedTask.Description;
                ImportantCheckBox.Checked = UpdatedTask.IsImportant;
            }
            else
            {
                Text = "Add task";
                RemoveBtn.Enabled = false;
                DueDateTimePicker.Value = DateTime.Today.AddDays(1);
            }

            //Update task id, subjects, icon
            IDLabel.Text += UpdatedTask.TaskID == -1 ? (TaskHost.SaveFile.Tasks.LastIndex + 1) : UpdatedTask.TaskID;
            UpdateSubjects();
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
            if (SubjectComboBox.SelectedIndex == -1)
            {
                SubjectComboBox.SelectedIndex = 1;
            }
        }

        private void UpdateSubjects()
        {
            //Remove old subjects
            int count = SubjectComboBox.Items.Count;
            for (int i = 2; i < count; i++)
            {
                SubjectComboBox.Items.RemoveAt(2);
            }

            //Add subjects
            SubjectComboBox.Items.AddRange(TaskHost.SaveFile.Subjects.Items.ToArray());
        }

        private void UpdateIcon()
        {
            TaskIconPictureBox.Image = UpdatedTask.GetIcon();
        }
        #endregion
        #region Form control update assignments
        private void TaskBodyTextBox_TextChanged(object sender, EventArgs e)
        {
            UpdatedTask.Name = TaskBodyTextBox.Text.Trim() == "" ? Task.UntitledTaskText : TaskBodyTextBox.Text.Trim();
        }

        private void DueDateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            UpdatedTask.DueDate = DueDateTimePicker.Checked ? DueDateTimePicker.Value : DateTime.MinValue;
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
        #region Subject updating functions
        private void SubjectComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (SubjectComboBox.SelectedItem is Subject subject)
            {
                UpdatedTask.SubjectID = subject.SubjectID;
            }
            else
            {
                switch (SubjectComboBox.SelectedIndex)
                {
                    case 0:
                        SubjectMgmtForm subjectForm = new(TaskHost);
                        subjectForm.ShowDialog();
                        UpdateSubjects();
                        SubjectComboBox.DroppedDown = true;
                        SubjectComboBox.SelectedIndex = SubjectComboBoxSelectionIndex < SubjectComboBox.Items.Count ? SubjectComboBoxSelectionIndex : 1;
                        break;
                    case 1:
                        UpdatedTask.SubjectID = -1;
                        break;
                }
            }
            SubjectComboBoxSelectionIndex = SubjectComboBox.SelectedIndex;
        }
        #endregion
        #endregion
    }
}
