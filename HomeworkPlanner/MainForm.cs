namespace HomeworkPlanner
{
    public partial class MainForm : Form
    {
        public enum DaysToInclude { Sunday = 1, Monday = 2, Tuesday = 4, Wednesday = 8, Thursday = 16, Friday = 32, Saturday = 64 }
        public int FutureWeeks = 2;
        public DaysToInclude DaysToDisplay { get; set; } = DaysToInclude.Monday | DaysToInclude.Tuesday | DaysToInclude.Wednesday | DaysToInclude.Thursday | DaysToInclude.Friday;
        private TaskHost TaskHost;
        public MainForm()
        {
            InitializeComponent();

            //Load tasks and set up controls
            InitializeTaskSystem();
            InitializeAllTasksPanel();
            InitializeStatusBar();
        }

        private void InitializeTaskSystem()
        {
            //TODO: Expand task init system (issue#8)
            TaskHost = new(new());
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
            Task[] alltasks = TaskHost.GetTasksPlannedForDate(DateTime.Today);
            (Task[] completed, Task[] remaining) tasks = TaskHost.FilterTasks(alltasks);

            toolStripStatusLabel1.Text = "Scheduled today: " + alltasks.Length;
            toolStripStatusLabel2.Text = "Completed: " + tasks.completed.Length;
            toolStripStatusLabel3.Text = "Remaining: " + tasks.remaining.Length;
            toolStripProgressBar1.Maximum = alltasks.Length;
            toolStripProgressBar1.Value = tasks.completed.Length;
        }

        private void UpdatePanels()

        {
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
                int index = TaskHost.GetTaskIndexById(originalTask.TaskID);
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
    }
}