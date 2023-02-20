using HomeworkPlanner.Properties;
using HomeworkPlanner.TaskControls;
using System.Diagnostics;

namespace HomeworkPlanner
{
    public partial class MainForm : Form
    {
        #region Properties and variables
        
        public int FutureWeeks { get { return TaskHost.SaveFile.Settings.FutureWeeks; } set { TaskHost.SaveFile.Settings.FutureWeeks = value; } }
        public bool Modified = false;
        public DaysToInclude DaysToDisplay { get { return TaskHost.SaveFile.Settings.DaysToDisplay; } set { TaskHost.SaveFile.Settings.DaysToDisplay = value; } }
        private TaskHost TaskHost { get; set; }
        private readonly ListViewItem NoRecentFilesLVI = new() { Text = "No recent files to display" };
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
                UpdateRecentFilesListView();
            }
        }
        #endregion

        #region Home panel handling

        public void UpdateTaskHostFunctions(bool enable)
        {
            saveToolStripMenuItem.Enabled = enable;
            saveAsToolStripMenuItem.Enabled = enable;
            importToolStripMenuItem1.Enabled = enable;

            tasksToolStripMenuItem.Visible = enable;
            importToolStripMenuItem.Enabled = enable;
            newToolStripMenuItem1.Enabled = enable;
            unscheduleTasksToolStripMenuItem.Enabled = enable;

            toolsToolStripMenuItem.Visible = enable;
            dayCancellingToolStripMenuItem.Enabled = enable;
            optionsToolStripMenuItem.Enabled = enable;

            customizeToolStripMenuItem.Enabled = enable;
            viewToolStripMenuItem.Visible = enable;
            weeksToolStripMenuItem.Enabled = enable;
            refreshToolStripMenuItem.Enabled = enable;
            statusStrip1.Visible = enable;

            button1.Enabled = enable;
        }

        private void UpdateRecentFilesListView()
        {
            listView1.Clear();

            List<string> list = Properties.Settings.Default.RecentFiles.Cast<string>().ToList();
            list.Reverse();
            if (list.Count > 0)
            {
                for (int i = 0; i < list.Count; i++)
                {
                    RecentFileListViewItem item = new() { FilePath = list[i], Text = list[i], ImageIndex = 0 };
                    listView1.Items.Add(item);
                }
            }
            else
            {
                listView1.Items.Add(NoRecentFilesLVI);
            }
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
                UpdateMenus();
                UpdatePanels();
                UpdateMenus();
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
            if (Properties.Settings.Default.EnableRecentFiles)
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
            UpdateMenus();
            UpdatePanels();
            Modified = false;
        }
        #endregion
        #region Visual initialization and updates
        
        //Main update methods
        /// <summary>
        /// Update all panes with latest taskctrl data -- call whenever tasks are updated
        /// </summary>
        /// <param name="changePerformed"></param>
        private void UpdatePanels(bool changePerformed = false)
        {
            UpdatePlanningPanel();
            UpdateAllTasksPanel();
            UpdateStatusBar();
            HandleChangePerformed(changePerformed);
        }
        /// <summary>
        /// Update all menus with latest info - call whenever menu options are changed
        /// </summary>
        /// <param name="changePerformed"></param>
        private void UpdateMenus(bool changePerformed = false)
        {
            UpdateWeekCountMenu();
            UpdateWeekDaysMenu(changePerformed);
            UpdateSortByMenu(changePerformed);
            UpdateSmallMenuOptions(changePerformed);
        }
        /// <summary>
        /// Handles performed changes -- only to be called from an Update method
        /// </summary>
        /// <param name="changePerformed"></param>
        private void HandleChangePerformed(bool changePerformed) => Modified = changePerformed ? true : Modified;

        //Panels and status bar - UpdatePanels
        private void UpdatePlanningPanel()
        {
            //Clear panel
            PlanningPanel.SuspendLayout();
            PlanningPanel.Controls.Clear();

            //Set up columns and rows
            int colCount = HelperFunctions.GetDayCount(DaysToDisplay);
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

            DateTime selectedDay = HelperFunctions.GetSunday(DateTime.Today).AddDays(6);
            for (int row = 0; row < rowCount; row++)
            {
                int col = colCount - 1;
                int DaysToDisplayData = (int)DaysToDisplay;
                for (int i = 64; i >= 1; i /= 2)
                {
                    if (DaysToDisplayData - i >= 0)
                    {
                        PlanningDayPanel control = new PlanningDayPanel(selectedDay, TaskHost);
                        control.ControlMouseDown += TaskControl_MouseDown;
                        control.ControlMouseUp += TaskControl_MouseUp;
                        control.ControlMouseMove += TaskControl_MouseMove;
                        control.CancelledDayClick += PlanningDay_CancelledDayClick;
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
        private void UpdateAllTasksPanel()
        {
            //Clear panel
            TasksFLP.Controls.Clear();
            List<Task> sortedArray = TaskHost.SortTasks(TaskHost.SaveFile.Settings.SortMethod, TaskHost.SaveFile.Tasks.Items);
            TasksFLP.SuspendLayout();
            //Add controls for all tasks
            foreach (Task task in sortedArray)
            {
                if (task.IsCompleted)
                {
                    if (task.DateCompleted != DateTime.Today)
                    {
                        if (!TaskHost.SaveFile.Settings.DisplayPreviousTasks)
                        {
                            continue;
                        }
                    }
                }
                TaskControl testctrl = new(TaskHost, task) { AutoSize = true };
                testctrl.MouseDown += TaskControl_MouseDown;
                testctrl.MouseUp += TaskControl_MouseUp;
                testctrl.MouseMove += TaskControl_MouseMove;
                TasksFLP.Controls.Add(testctrl);
            }
            TasksFLP.ResumeLayout();
        }
        private void UpdateStatusBar()
        {
            Task[] alltasks = TaskHost.GetTasksPlannedForDate(DateTime.Today);
            (Task[] completed, Task[] remaining) tasks = TaskHost.FilterTasks(alltasks);

            toolStripStatusLabel1.Text = "Scheduled today: " + alltasks.Length;
            toolStripStatusLabel2.Text = "Completed: " + tasks.completed.Length;
            toolStripStatusLabel3.Text = "Remaining: " + tasks.remaining.Length;
            toolStripProgressBar1.Maximum = alltasks.Length;
            toolStripProgressBar1.Value = tasks.completed.Length;
        }

        //Menus - UpdateMenus
        private void UpdateWeekCountMenu()
        {
            for (int i = 0; i < weekItems.Length; i++)
            {
                weekItems[i].Checked = false;
            }
            weekItems[FutureWeeks].Checked = true;
        }
        private void UpdateWeekDaysMenu(bool changePerformed = false)
        {
            int data = (int)DaysToDisplay;
            var menus = weekDaysToolStripMenuItem.DropDownItems;

            //Uncheck all
            for (int i = 0; i < menus.Count; i++)
            {
                ((ToolStripMenuItem)menus[i]).Checked = false;
            }

            //Check only the ones that correspond to a week day displayed;
            int weekDay = 6;
            for (int i = 64; i >= 1; i /= 2)
            {
                if (data - i >= 0)
                {
                    ((ToolStripMenuItem)menus[weekDay]).Checked = true;
                    data -= i;
                }
                weekDay--;
            }

            //Handle changes
            HandleChangePerformed(changePerformed);
        }
        private void UpdateSortByMenu(bool changePerformed = false)
        {
            int menuToCheck = (int)TaskHost.SaveFile.Settings.SortMethod;
            var menus = sortByToolStripMenuItem.DropDownItems;

            for (int i = 0; i < menus.Count; i++)
            {
                ((ToolStripMenuItem)menus[i]).Checked = false;
            }

            ((ToolStripMenuItem)menus[menuToCheck]).Checked = true;

            HandleChangePerformed(changePerformed);
        }
        private void SortByItemClick(object sender, EventArgs e)
        {
            var menu = (ToolStripMenuItem)sender;
            TaskHost.SaveFile.Settings.SortMethod = (SortMethod)sortByToolStripMenuItem.DropDownItems.IndexOf(menu);
            UpdateMenus(true);
            UpdatePanels(false);
        }

        private void UpdateSmallMenuOptions(bool changePerformed = false)
        {
            //Set check state
            displayPreviousTasksToolStripMenuItem.Checked = TaskHost.SaveFile.Settings.DisplayPreviousTasks;
            HandleChangePerformed(changePerformed);
        }

        #endregion
        #region Control mouse interaction

        bool MouseMoved = false;
        bool isClicking = false;
        private void TaskControl_MouseUp(object? sender, MouseEventArgs e)
        {
            if (sender != null)
            {
                TaskControl taskctrl = ((TaskControl)sender);
                if (MouseMoved)
                {
                    Point mousepos = Cursor.Position;
                    Control control = this;
                    for (int i = 1; i <= 4; i++)
                    {
                        control = control.GetChildAtPoint(control.PointToClient(mousepos));
                        if (control != null)
                        {
                            if (control.GetType() == typeof(PlanningDayPanel))
                            {
                                taskctrl.SelectedTask.ExecDate = ((PlanningDayPanel)control).SelectedDay;
                                break;
                            }
                            if (control.GetType() == typeof(FlowLayoutPanel) && control.Name == TasksFLP.Name)
                            {
                                taskctrl.SelectedTask.ExecDate = null;
                                break;
                            }
                        }
                        else
                        {
                            break;
                        }
                    }
                    UpdatePanels(true);
                }
                else if (e.Button == MouseButtons.Right)
                {
                    TaskControl_Click(sender, e);
                }
                else if (e.Button == MouseButtons.Left)
                {
                    taskctrl.SelectedTask.IsCompleted = !taskctrl.SelectedTask.IsCompleted;
                    UpdatePanels(true);
                }
                MouseMoved = false;
                isClicking = false;
                Cursor = Cursors.Default;
            }
        }
        private void TaskControl_MouseDown(object? sender, MouseEventArgs e)
        {
            if (sender != null)
            {
                isClicking = true;
            }
        }

        private void TaskControl_MouseMove(object? sender, MouseEventArgs e)
        {
            if (!MouseMoved && isClicking)
            {
                MouseMoved = true;
                Cursor = new Cursor(new MemoryStream(Properties.Resources.drag_task));
            }
        }

        private void PlanningDay_CancelledDayClick(object sender, PlanningDayPanel.CancelledDayEventArgs e)
        {
            if (MessageBox.Show((e.SelectedDayNote.Cancelled ? "This day has been cancelled and given the message:\n\n" : "This day has the following note:\n\n") + e.SelectedDayNote.Message + "\n\nClick OK to remove it", (e.SelectedDayNote.Cancelled ? "Cancelled day" : "Day note"), MessageBoxButtons.OKCancel, MessageBoxIcon.Information) == DialogResult.OK)
            {
                TaskHost.SaveFile.DayNotes.Remove(e.SelectedDayNote);
                UpdatePanels();
            }
        }
        #endregion
        #region MenuItem option on changing number of weeks displayed

        private readonly ToolStripMenuItem[] weekItems;

        private void changeWeekCount(object sender, EventArgs e)
        {
            FutureWeeks = Convert.ToInt32(((ToolStripMenuItem)sender).Text) - 1;
            UpdateWeekCountMenu();
            UpdatePlanningPanel();
        }

        #endregion
        #region Task addition and modification

        private void AddTask()
        {
            TaskForm tform = new(TaskHost, new Task(), true) { StartPosition = FormStartPosition.CenterParent};
            if (tform.ShowDialog() == DialogResult.OK)
            {
                TaskHost.SaveFile.Tasks.Add(tform.UpdatedTask);
                UpdatePanels(true);
            }
        }

        private void TaskControl_Click(object? sender, EventArgs e)
        {
            Task originalTask = ((TaskControl)sender).SelectedTask;
            TaskForm tForm = new(TaskHost, originalTask) { StartPosition = FormStartPosition.CenterParent};
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
            UpdateRecentFiles(fileName);
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

        private void listView1_OpenRecentFile(object sender, EventArgs e)
        {
            if (listView1.SelectedItems[0] != NoRecentFilesLVI)
            {
                LoadSaveFile(((RecentFileListViewItem)listView1.SelectedItems[0]).FilePath);
            }
        }

        private void recentFilesToolStripMenuItem_DropDownOpened(object sender, EventArgs e)
        {
            UpdateRecentFilesMenu();
        }

        private void UpdateRecentFilesMenu()
        {
            int x = recentFilesToolStripMenuItem.DropDownItems.Count;
            for (int i = 2; i < x; i++)
            {
                recentFilesToolStripMenuItem.DropDownItems.RemoveAt(2);
            }

            List<string> files = Properties.Settings.Default.RecentFiles.Cast<string>().ToList();
            files.Reverse();
            //files.Clear();
            if (files.Count > 0)
            {
                for (int i = 0; i < files.Count; i++)
                {
                    ToolStripMenuItem item = new() { Text = files[i] };
                    item.Click += RecentFileMenuItem_Click;
                    recentFilesToolStripMenuItem.DropDownItems.Add(item);
                }
            }
            else
            {
                recentFilesToolStripMenuItem.DropDownItems.Add(noFilesToDisplayToolStripMenuItem);
            }
        }

        private void RecentFileMenuItem_Click(object? sender, EventArgs e)
        {
            LoadSaveFile(((ToolStripMenuItem)sender).Text);
        }

        private void clearRecentsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Properties.Settings.Default.RecentFiles.Clear();
            Properties.Settings.Default.Save();
            if (HomeDisplaying)
            {
                UpdateRecentFilesListView();
            }
        }

        private void dayCancellingToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DayCancelForm dayCancelForm = new();
            if (dayCancelForm.ShowDialog() == DialogResult.OK)
            {
                TaskHost.SaveFile.DayNotes.Add(new() { Date = dayCancelForm.Date, Message = dayCancelForm.Message, Cancelled = dayCancelForm.IsCancelled });
                UpdatePanels(true);
            }
        }

        private void removeCompletedTasksToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("This option will remove all tasks marked as completed\nAre you sure you want to continue? This action cannot be undone", "Warning", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Warning) == DialogResult.Yes)
            {
                TaskHost.RemoveCompletedTasks();
                UpdatePanels();
            }
        }

        #region Handles changing week days displayed

        void HandleDayChange(DaysToInclude day, ToolStripMenuItem item)
        {
            item.Checked = !item.Checked;
            int data = (int)DaysToDisplay;
            if (item.Checked)
            {
                data += (int)day;
            }
            else
            {
                data -= (int)day;
            }
            DaysToDisplay = (DaysToInclude)data;
            UpdateWeekDaysMenu();
            UpdatePanels(true);
        }

        
        private void weekday_change_click(object sender, EventArgs e)
        {
            DaysToInclude day;
            ToolStripMenuItem tsmi = (ToolStripMenuItem)sender;
            switch (tsmi.Text)
            {
                case "Sunday":
                    day = DaysToInclude.Sunday; break;
                case "Monday":
                    day = DaysToInclude.Monday; break;
                case "Tuesday":
                    day = DaysToInclude.Tuesday; break;
                case "Wednesday":
                    day = DaysToInclude.Wednesday; break;
                case "Thursday":
                    day = DaysToInclude.Thursday; break;
                case "Friday":
                    day = DaysToInclude.Friday; break;
                case "Saturday":
                    day = DaysToInclude.Saturday; break;
                default:
                    return;
            }

            HandleDayChange(day, tsmi);
        }

        #endregion
        
        private void displayPreviousTasksToolStripMenuItem_Click(object sender, EventArgs e)
        {
            TaskHost.SaveFile.Settings.DisplayPreviousTasks = !displayPreviousTasksToolStripMenuItem.Checked;
            UpdatePanels(true);
            UpdateSmallMenuOptions(true);
        }

        private void optionsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("This action will attempt to declutter big or slow save files by removing old tasks and resetting task IDs\nThis action cannot be easily undone, make sure you back up before proceeding\n\nDo you want to continue?", "Cleanup", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
            {
                TaskHost.Repair();
                UpdatePanels(true);
            }
        }

        private void removeAllTasksToolStripMenuItem_Click(object sender, EventArgs e)
        {
            for (int i = 1; i <= 3; i++)
            {
                if (MessageBox.Show("This action will REMOVE ALL TASKS independant of due date, completion or other values\nThis action cannot be undone\nPress \"Yes\" three times to confirm\n\nMessage " + i + " of 3", "Warning", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.No)
                {
                    return;
                }
            }
            TaskHost.RemoveAllTasks();
            UpdatePanels();
        }

        private void importToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (new ImportDialog(TaskHost).ShowDialog() == DialogResult.OK)
            {
                UpdatePanels(true);
                UpdateMenus(true);
            }
        }

        private void reportToolStripMenuItem_Click(object sender, EventArgs e)
        {
            new ReportForm(TaskHost).ShowDialog();
        }

        private void everythingToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("Are you sure you want to unschedule all tasks? This option includes tasks marked as completed.\nThis action cannot be undone", "Unschedule all", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
            {
                TaskHost.UnscheduleAllTasks();
                UpdatePanels(true);
            }
        }

        private void remainingOnlyToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("Are you sure you want to unschedule all remaining tasks?\nThis action cannot be undone", "Unschedule all", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
            {
                TaskHost.UnscheduleAllTasks(true);
                UpdatePanels(true);
            }
        }

        private void classSchedulesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            new ScheduleForm(TaskHost).ShowDialog();
            Modified = true;
        }
    }
}