using HomeworkPlanner.Properties;
using HomeworkPlanner.TaskControls;
using System.Diagnostics;

namespace HomeworkPlanner
{
    public partial class MainForm : Form
    {
        #region Properties and variables
        public enum DaysToInclude { Sunday = 1, Monday = 2, Tuesday = 4, Wednesday = 8, Thursday = 16, Friday = 32, Saturday = 64 }
        public int FutureWeeks { get; set; } = 2;
        public bool Modified = false;
        public DaysToInclude DaysToDisplay { get; set; } = DaysToInclude.Monday | DaysToInclude.Tuesday | DaysToInclude.Wednesday | DaysToInclude.Thursday | DaysToInclude.Friday;
        private TaskHost TaskHost { get; set; }
        private bool _HomeDisplaying = true;
        public bool HomeDisplaying { get { return _HomeDisplaying; }
            set
            {
                if (!value && _HomeDisplaying == true)
                {
                    _HomeDisplaying = false;
                    Controls.Remove(tableLayoutPanel2);
                    UpdateTaskHostFunctions(!value);
                }
            }
        }
        #endregion
        #region Main Constructor
        public MainForm(string? saveFilePath = null)
        {
            InitializeComponent();
            weekItems = new ToolStripMenuItem[] { OneWeekMenuItem, TwoWeekMenuItem, ThreeWeekMenuItem, FourWeekMenuItem, FiveWeekMenuItem };
            Text = Application.ProductName + " " + Application.ProductVersion;
            if (saveFilePath != null)
            {
                LoadSaveFile(saveFilePath);
            }
            else
            {
                //Initialize home panel
                UpdateTaskHostFunctions(false);
                UpdateRecentFilesList();
            }
        }
        #endregion

        #region Home panel handling

        public void UpdateTaskHostFunctions(bool enable)
        {
            saveToolStripMenuItem.Enabled = enable;
            saveAsToolStripMenuItem.Enabled = enable;

            tasksToolStripMenuItem.Visible = enable;
            newToolStripMenuItem1.Enabled = enable;
            unscheduleAllToolStripMenuItem.Enabled = enable;

            customizeToolStripMenuItem.Enabled = enable;
            viewToolStripMenuItem.Visible = enable;
            weeksToolStripMenuItem.Enabled = enable;
            refreshToolStripMenuItem.Enabled = enable;
            statusStrip1.Visible = enable;
        }

        #endregion

        #region Task system initialization
        private void LoadSaveFile(string saveFilePath)
        {
            if (File.Exists(saveFilePath))
            {
                HomeDisplaying = false;
                TaskHost = new(SaveFile.FromJSON(File.ReadAllText(saveFilePath)), saveFilePath);
                UpdateRecentFiles(saveFilePath);
                UpdateFilePathTitle();
                UpdatePanels();
                Modified = false;
            }
            else
            {
                MessageBox.Show("Couldn't open file \"" + saveFilePath + "\": File not found","File not found",MessageBoxButtons.OK, MessageBoxIcon.Error);
                UpdateRecentFiles(saveFilePath,false);
            }
        }

        private void UpdateRecentFiles(string filePath, bool remove = false)
        {
            if (Properties.Settings.Default.RecentFiles.Contains(filePath))
            {
                Properties.Settings.Default.RecentFiles.Remove(filePath);
                if (!remove)
                {
                    Properties.Settings.Default.RecentFiles.Add(filePath);
                }
            }
            else
            {
                Properties.Settings.Default.RecentFiles.Add(filePath);
            }
            Properties.Settings.Default.Save();
        }

        private void UpdateFilePathTitle()
        {
            Text = Application.ProductName+ " " + Application.ProductVersion + " - [" + TaskHost.SaveFilePath + "]";
        }

        private void InitializeNewTaskSystem()
        {
            HomeDisplaying = false;
            TaskHost = new(new(), null);
            Text = Application.ProductName + " " + Application.ProductVersion + " - [untitled.hwpf]";
            UpdatePanels();
            Modified = false;
        }
        #endregion
        #region Visual initialization and updates
        private void InitializePlanningPanel()
        {
            //Clear panel
            PlanningPanel.Controls.Clear();
            PlanningPanel.SuspendLayout();

            //Set up columns and rows
            int colCount = GetDayCount(DaysToDisplay);
            int rowCount = FutureWeeks + 1;

            PlanningPanel.ColumnCount = colCount;
            for (int i = 0; i < colCount; i++)
            {
                PlanningPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            }
            PlanningPanel.RowCount = rowCount;
            for (int i = 0; i < colCount; i++)
            {
                PlanningPanel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            }

            DateTime selectedDay = GetSunday(DateTime.Today).AddDays(6);
            for (int row = 0; row < rowCount; row++)
            {
                int col = colCount - 1;
                int DaysToDisplayData = (int)DaysToDisplay;
                for (int i = 64; i >= 1; i /= 2)
                {
                    if (DaysToDisplayData - i >= 0)
                    {
                        PlanningDayPanel control = InitializePlanningDayControl(selectedDay);
                        control.ControlMouseDown += TaskControl_MouseOperation;
                        control.ControlMouseUp += TaskControl_DragConfirm;
                        PlanningPanel.Controls.Add(control, col, row);
                        DaysToDisplayData -= i;
                        col--;
                    }
                    selectedDay = selectedDay.Subtract(TimeSpan.FromDays(1));
                }
                selectedDay = selectedDay.AddDays(14);
            }
            PlanningPanel.ResumeLayout();
        }
        private void InitializeAllTasksPanel()
        {
            //Clear panel
            TasksFLP.Controls.Clear();
            Task[] sortedArray = TaskHost.SortTasksByDueDate(TaskHost.SaveFile.Tasks.Items.ToArray());
            
            //Add controls for all tasks
            foreach (Task task in sortedArray)
            {
                if (task.IsCompleted)
                {
                    if (task.DateCompleted != DateTime.Today)
                    {
                        continue;
                    }
                }
                TaskControl testctrl = new(TaskHost, task) { AutoSize = true };
                testctrl.MouseDown += TaskControl_MouseOperation;
                testctrl.MouseUp += TaskControl_DragConfirm;
                TasksFLP.Controls.Add(testctrl);
            }
        }
        private void InitializeStatusBar()
        {
            Task[] alltasks = TaskHost.GetTasksPlannedForDate(DateTime.Today);
            (Task[] completed, Task[] remaining) tasks = TaskHost.FilterTasks(alltasks);

            toolStripStatusLabel1.Text = "Scheduled today: " + alltasks.Length;
            toolStripStatusLabel2.Text = "Completed: " + tasks.completed.Length;
            toolStripStatusLabel3.Text = "Remaining: " + tasks.remaining.Length;
            toolStripProgressBar1.Maximum = alltasks.Length;
            toolStripProgressBar1.Value = tasks.completed.Length;
        }
        private PlanningDayPanel InitializePlanningDayControl(DateTime day)
        {
            return new PlanningDayPanel(day, TaskHost);
        }
        private void UpdatePanels(bool changePerformed = false)
        {
            InitializePlanningPanel();
            InitializeAllTasksPanel();
            InitializeStatusBar();
            Modified = changePerformed ? true : Modified;
        }
        #endregion
        #region TaskControl mouse interaction
        private void TaskControl_DragConfirm(object? sender, MouseEventArgs e)
        {
            if (sender != null)
            {
                TaskControl task = ((TaskControl)sender);
                if (task.IsDragging)
                {
                    Point mousepos = Cursor.Position;
                    Control control = this;
                    for (int i = 1; i <= 4; i++)
                    {
                        control = control.GetChildAtPoint(control.PointToClient(mousepos));
                        if (control.GetType() == typeof(PlanningDayPanel))
                        {
                            if (!((PlanningDayPanel)control).IsCancelled)
                            {
                                task.SelectedTask.ExecDate = ((PlanningDayPanel)control).SelectedDay;
                                UpdatePanels(true);
                                Cursor = Cursors.Default;
                                return;
                            }
                        }
                        if (control.GetType() == typeof(FlowLayoutPanel) && control.Name == TasksFLP.Name)
                        {
                            task.SelectedTask.ExecDate = null;
                            UpdatePanels(true);
                            Cursor = Cursors.Default;
                            return;
                        }
                    }
                }
            }
        }

        private void TaskControl_MouseOperation(object? sender, MouseEventArgs e)
        {
            if (sender != null)
            {
                TaskControl task = ((TaskControl)sender);
                if (e.Button == MouseButtons.Middle)
                {
                    task.IsDragging = true;
                    Cursor = new Cursor("drag_task.cur");
                }
                else if (e.Button == MouseButtons.Right)
                {
                    TaskControl_Click(sender, e);
                }
                else
                {
                    task.SelectedTask.IsCompleted = !task.SelectedTask.IsCompleted;
                    UpdatePanels(true);
                }
            }
        }
        #endregion
        #region Auxiliary methods for date calculation

        private static DateTime GetSunday(DateTime dateTime)
        {
            DayOfWeek dayOfWeek = dateTime.DayOfWeek;

            return dateTime.AddDays(0 - (double)dayOfWeek);
        }

        private static int GetDayCount(DaysToInclude data)
        {
            int numericData = (int)data;
            int dayCount = 0;
            for (int i = 64; i >= 1; i /= 2)
            {
                if (numericData - i >= 0)
                {
                    dayCount++;
                    numericData -= i;
                }
            }
            return dayCount;
        }

        #endregion
        #region MenuItem option on changing number of weeks displayed

        private readonly ToolStripMenuItem[] weekItems;

        private void changeWeekCount(object sender, EventArgs e)
        {
            FutureWeeks = Convert.ToInt32(((ToolStripMenuItem)sender).Text) - 1;
            for (int i = 0; i < weekItems.Length; i++)
            {
                weekItems[i].Checked = false;
            }
            weekItems[FutureWeeks].Checked = true;
            InitializePlanningPanel();
        }

        #endregion
        #region Task addition and modification

        private void AddTask()
        {
            TaskForm tform = new(TaskHost, new Task(), true);
            if (tform.ShowDialog() == DialogResult.OK)
            {
                TaskHost.SaveFile.Tasks.Add(tform.UpdatedTask);
                UpdatePanels(true);
            }
        }

        private void TaskControl_Click(object? sender, EventArgs e)
        {
            Task originalTask = ((TaskControl)sender).SelectedTask;
            TaskForm tForm = new(TaskHost, originalTask);
            DialogResult dr = tForm.ShowDialog();
            if (dr == DialogResult.OK)
            {
                int index = TaskHost.GetTaskIndexById(originalTask.TaskID);
                if (index != -1)
                {
                    TaskHost.SaveFile.Tasks.Items[index] = tForm.UpdatedTask;
                }
                else
                {
                    TaskHost.SaveFile.Tasks.Add(tForm.UpdatedTask);
                }
                UpdatePanels(true);
            }
            if (dr == DialogResult.Abort)
            {
                int index = TaskHost.GetTaskIndexById(originalTask.TaskID);
                if (index != -1)
                {
                    TaskHost.SaveFile.Tasks.Items.RemoveAt(index);
                }
                else
                {
                    MessageBox.Show("Failed to delete task, it could have already been deleted", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                UpdatePanels(true);
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            AddTask();
        }

        private void newToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            AddTask();
        }

        #endregion
        #region Menu item functions
        private void refreshToolStripMenuItem_Click(object sender, EventArgs e)
        {
            UpdatePanels();
        }
        private void customizeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SubjectMgmtForm subjectMgmtForm = new(TaskHost);
            subjectMgmtForm.ShowDialog();
            UpdatePanels(true);
        }
        private void unscheduleAllToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("Are you sure you want to unschedule all tasks?\nThis action cannot be undone", "Unschedule all", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
            {
                TaskHost.UnscheduleAllTasks();
                UpdatePanels(true);
            }
        }
        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }
        #endregion
        #region File operations
        private void New_Click(object sender, EventArgs e)
        {
            InitializeNewTaskSystem();
        }

        private void OpenFile_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new() { Title = "Select a save file...", Filter = "HomeworkPlanner files (*.hwpf)|*.hwpf" };
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                LoadSaveFile(ofd.FileName);
            }
        }

        private void SaveAs_Click(object sender, EventArgs e)
        {
            SaveFileDialog sfd = new() { Title = "Save as...", Filter = "HomeworkPlanner files (*.hwpf)|*.hwpf" };
            if (sfd.ShowDialog() == DialogResult.OK)
            {
                WriteDataToFile(sfd.FileName);
            }
        }

        private void Save_Click(object sender, EventArgs e)
        {
            if (TaskHost.SaveFilePath != null)
            {
                WriteDataToFile(TaskHost.SaveFilePath);
            }
            else
            {
                SaveAs_Click(sender, EventArgs.Empty);
            }
        }

        private void WriteDataToFile(string fileName)
        {
            string data = TaskHost.SaveFile.MakeJSON();
            File.WriteAllText(fileName, data);
            TaskHost.SaveFilePath = fileName;
            UpdateFilePathTitle();
            Modified = false;
        }

        #endregion
        #region Closing handling function
        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (Modified)
            {
                DialogResult dr = MessageBox.Show("Do you want to save \"" + (TaskHost.SaveFilePath == null ? "untitled" : TaskHost.SaveFilePath) + "\"?", "Warning", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Warning);
                switch (dr)
                {
                    case DialogResult.Cancel:
                        e.Cancel = true;
                        break;
                    case DialogResult.Yes:
                        Save_Click(sender, EventArgs.Empty);
                        break;
                    case DialogResult.No:
                        //do nothing
                        break;
                }
            }
        }
        #endregion
        #region Getting help
        private void GetHelp()
        {
            Process.Start(new ProcessStartInfo(Properties.Settings.Default.GetHelpWebsite) { UseShellExecute = true});
        }

        private void getHelpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            GetHelp();
        }

        private void linkLabel4_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            GetHelp();
        }
        #endregion

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            new AboutForm().ShowDialog();
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            InitializeNewTaskSystem();
        }

        private void linkLabel2_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            OpenFile_Click(sender, e);
        }

        private void linkLabel3_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            //TODO: Implement options menu item
            throw new NotImplementedException();
        }

        private void UpdateRecentFilesList()
        {
            List<string> list = Properties.Settings.Default.RecentFiles.Cast<string>().ToList();
            list.Reverse();
            for (int i = 0; i < list.Count; i++)
            {
                RecentFileListViewItem item = new() { FilePath = list[i], Text = list[i], ImageIndex = 0 };
                listView1.Items.Add(item);
            }
            if (list.Count != 0)
            {
                listView1.Items.RemoveAt(0);
            }
        }

        private class RecentFileListViewItem : ListViewItem
        {
            public string FilePath { get; set; }
        }

        private void listView1_ItemActivate(object sender, EventArgs e)
        {
            LoadSaveFile(((RecentFileListViewItem)listView1.SelectedItems[0]).FilePath);
        }

        private void dayCancellingToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DayCancelForm dayCancelForm = new();
            if (dayCancelForm.ShowDialog() == DialogResult.OK)
            {
                TaskHost.SaveFile.CancelledDays.Add(new() { Date = dayCancelForm.Date, Message = dayCancelForm.Message });
                MessageBox.Show("Cancelled day added successfully!", "Message", MessageBoxButtons.OK, MessageBoxIcon.Information);
                UpdatePanels(true);
            }
        }
    }
}