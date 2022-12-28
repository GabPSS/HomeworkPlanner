namespace HomeworkPlanner
{
    public partial class MainForm : Form
    {
        public enum DaysToInclude { Sunday = 1, Monday = 2, Tuesday = 4, Wednesday = 8, Thursday = 16, Friday = 32, Saturday = 64 }
        public int FutureWeeks = 2;
        public DaysToInclude DaysToDisplay { get; set; } = DaysToInclude.Monday | DaysToInclude.Tuesday | DaysToInclude.Wednesday | DaysToInclude.Thursday | DaysToInclude.Friday;
        private TaskHost TaskHost;
        public MainForm(string? saveFilePath = null)
        {
            InitializeComponent();
            weekItems = new ToolStripMenuItem[] { OneWeekMenuItem, TwoWeekMenuItem, ThreeWeekMenuItem, FourWeekMenuItem, FiveWeekMenuItem };
            
            //Load tasks and set up controls
            if (saveFilePath != null)
            {
                LoadSaveFile(saveFilePath);
            }
            else
            {
                InitializeNewTaskSystem();
            }
        }

        private void LoadSaveFile(string saveFilePath)
        {
            TaskHost = new(SaveFile.FromJSON(File.ReadAllText(saveFilePath)));
            UpdatePanels();
        }

        private void InitializeNewTaskSystem()
        {
            TaskHost = new(new());
            UpdatePanels();
        }

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
                        TableLayoutPanel control = InitializePlanningDayControl(selectedDay);
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

        private TableLayoutPanel InitializePlanningDayControl(DateTime day)
        {
            //Add main container
            TableLayoutPanel tlp = new() { ColumnCount = 1, RowCount = 2, Dock = DockStyle.Fill };
            tlp.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            tlp.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            //Add top label
            Label lbl = new()
            {
                Text = day.ToString("dd"),
                Dock = DockStyle.Fill
            };
            tlp.Controls.Add(lbl, 0, 0);

            //Add flowLayoutPanel
            FlowLayoutPanel flp = new() { Dock = DockStyle.Fill, FlowDirection = FlowDirection.TopDown, AutoScroll = true, WrapContents = false };
            tlp.Controls.Add(flp, 0, 1);

            //Add tasks
            Task[] dayTasks = TaskHost.GetTasksPlannedForDate(day);
            foreach (Task task in dayTasks)
            {
                TaskControl ctrl = new(TaskHost, task) { AutoSize = true, DrawMode = TaskControl.TaskDrawMode.Planner };
                ctrl.Click += TaskControl_Click;
                flp.Controls.Add(ctrl);
            }
            return tlp;
        }

        private void InitializeAllTasksPanel()
        {
            //Clear panel
            TasksFLP.Controls.Clear();

            //Add controls for all tasks
            foreach (Task task in TaskHost.SaveFile.Tasks.Items)
            {
                TaskControl testctrl = new(TaskHost, task) { AutoSize = true };
                testctrl.Click += TaskControl_Click; 
                TasksFLP.Controls.Add(testctrl);
            }
        }

        private void InitializeStatusBar()
        {
            var alltasks = TaskHost.GetTasksPlannedForDate(DateTime.Today);
            var tasks = TaskHost.FilterTasks(alltasks);
            
            toolStripStatusLabel1.Text = "Scheduled today: " + alltasks.Length;
            toolStripStatusLabel2.Text = "Completed: " + tasks.completed.Length;
            toolStripStatusLabel3.Text = "Remaining: " + tasks.remaining.Length;
            toolStripProgressBar1.Maximum = alltasks.Length;
            toolStripProgressBar1.Value = tasks.completed.Length;
        }

        private void UpdatePanels()
        {
            InitializePlanningPanel();
            InitializeAllTasksPanel();
            InitializeStatusBar();
        }

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

        private void refreshToolStripMenuItem_Click(object sender, EventArgs e)
        {
            UpdatePanels();
        }

        #region Task addition and modification

        private void AddTask()
        {
            TaskForm tform = new(TaskHost, new Task(), true);
            if (tform.ShowDialog() == DialogResult.OK)
            {
                TaskHost.SaveFile.Tasks.Add(tform.UpdatedTask);
                UpdatePanels();
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
                UpdatePanels();
            }
            if (dr == DialogResult.Abort)
            {
                int index = TaskHost.GetTaskIndexById((int)originalTask.TaskID);
                if (index != -1)
                {
                    TaskHost.SaveFile.Tasks.Items.RemoveAt(index);
                }
                else
                {
                    MessageBox.Show("Failed to delete task, it could have already been deleted", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                UpdatePanels();
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

        private void customizeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SubjectMgmtForm subjectMgmtForm = new(TaskHost);
            subjectMgmtForm.ShowDialog();
            UpdatePanels();
        }

        private void openToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new() { Title = "Select a save file...", Filter = "HomeworkPlanner files (*.hwpf)|*.hwpf" };
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                LoadSaveFile(ofd.FileName);
            }
        }

        private void saveAsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SaveFileDialog sfd = new() { Title = "Save as...", Filter = "HomeworkPlanner files (*.hwpf)|*.hwpf" };
            if (sfd.ShowDialog() == DialogResult.OK)
            {
                string data = TaskHost.SaveFile.MakeJSON();
                File.WriteAllText(sfd.FileName, data);
            }
        }

        private void newToolStripMenuItem_Click(object sender, EventArgs e)
        {
            InitializeNewTaskSystem();
        }
    }
}