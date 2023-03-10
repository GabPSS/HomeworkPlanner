using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HomeworkPlanner.TaskControls
{
    internal class TaskControl : Control
    {
        #region Properties and variables
        #region Internal definitions
        public enum TaskDrawMode { Planner, TasksView }
        #endregion
        #region Public properties and variables
        public TaskDrawMode DrawMode { get; set; } = TaskDrawMode.TasksView;
        public TaskHost TaskHandler { get; set; }
        public Task SelectedTask { get; set; }
        public bool IsDragging = false;
        public Font DefaultTitleFont { get; set; }
        public Font DefaultCompletedTitleFont { get; set; }
        public Font DefaultDueFont { get; set; }
        public Font DefaultDescFont { get; set; }
        public Font DefaultCompletedDescFont { get; set; } 
        public Font DefaultCompletedFont { get; set; }

        public int ZoomFactor { get; set; }
        /// <summary>
        /// Defines if the control should be sized automatically
        /// </summary>
        [DefaultValue(true)]
        public override bool AutoSize { get => base.AutoSize; set => base.AutoSize = value; }
        #endregion
        #region Internal properties
        private Image Icon { get { return SelectedTask.GetIcon(); } }
        private Brush DrawingBrush { get { return new SolidBrush(ForeColor); } }
        #endregion
        #endregion
        #region Default constructor and control methods
        public TaskControl(TaskHost taskHandler, Task selectedTask)
        {
            TaskHandler = taskHandler;
            SelectedTask = selectedTask;
            ZoomFactor = Properties.Settings.Default.ZoomFactor / 10;
            DefaultTitleFont = new Font(FontFamily.GenericSansSerif, ZoomFactor, FontStyle.Bold);
            DefaultCompletedTitleFont = new Font(FontFamily.GenericSansSerif, ZoomFactor, FontStyle.Strikeout);
            DefaultDueFont = new Font(FontFamily.GenericSansSerif, ZoomFactor);
            DefaultDescFont = new Font(FontFamily.GenericSansSerif, ZoomFactor * 0.8f);
            DefaultCompletedDescFont = new Font(FontFamily.GenericSansSerif, ZoomFactor * 0.8f, FontStyle.Strikeout);
            DefaultCompletedFont = new Font(FontFamily.GenericSansSerif, ZoomFactor, FontStyle.Strikeout);
        }
        public override Size GetPreferredSize(Size proposedSize)
        {
            return MeasureControl(CreateGraphics());
        }
        protected override void OnPaint(PaintEventArgs e)
        {
            DrawControl(e.Graphics);
        }
        #endregion
        #region Graphics-handling functions
        private void DrawControl(Graphics gfx)
        {
            int imgDimension = Convert.ToInt32(ZoomFactor * 3.2);
            gfx.Clear(BackColor);
            gfx.DrawImage(Icon, 0, 0, imgDimension, imgDimension);

            SizeF TitleMeasurement = gfx.MeasureString(GetTitle(), SelectedTask.IsCompleted ? DefaultCompletedTitleFont : DefaultTitleFont);
            gfx.DrawString(GetTitle(), SelectedTask.IsCompleted ? DefaultCompletedTitleFont : DefaultTitleFont, DrawingBrush, imgDimension + 2, 0);
            float text_y = TitleMeasurement.Height + 3;
            float text_x = imgDimension + 2;
            
            switch (DrawMode)
            {
                case TaskDrawMode.Planner:
                    gfx.DrawString(SelectedTask.DueDate == DateTime.MinValue ? "No due date" : ("Due: " + SelectedTask.DueDate.ToString("dd/MM")), SelectedTask.IsCompleted ? DefaultCompletedFont : DefaultDueFont, DrawingBrush, text_x, text_y);
                    break;
                case TaskDrawMode.TasksView:
                    float descTextHeight = gfx.MeasureString("This is a test string", DefaultDescFont).Height;
                    for (int i = 0; i < SelectedTask.Description.Length; i++)
                    {
                        //TODO: Implement text wrapping
                        gfx.DrawString(SelectedTask.Description[i], SelectedTask.IsCompleted ? DefaultCompletedDescFont : DefaultDescFont, DrawingBrush, text_x, text_y);
                        text_y += descTextHeight + 2;
                    }
                    break;
            }
        }
        /// <summary>
        /// Calculates the final width and height of the control that will be drawn
        /// </summary>
        private Size MeasureControl(Graphics gfx)
        {
            float width, height, imgwidth, imgheight, titleWidth, bodyWitdh = 0, txtheight = 0;

            imgwidth = ZoomFactor * 3.2f;
            imgheight = ZoomFactor * 3.2f;

            SizeF TitleMeasurement = gfx.MeasureString(GetTitle(), DefaultTitleFont);
            titleWidth = TitleMeasurement.Width;

            switch (DrawMode)
            {
                case TaskDrawMode.Planner:
                    SizeF BodyMeasurement = gfx.MeasureString("Due: " + SelectedTask.DueDate.ToString("dd/MM"), DefaultDueFont);
                    txtheight = TitleMeasurement.Height + 3 + BodyMeasurement.Height;
                    bodyWitdh = BodyMeasurement.Width;
                    break;
                case TaskDrawMode.TasksView:
                    txtheight = TitleMeasurement.Height + 3;
                    float descTextHeight = gfx.MeasureString("This is a test string", DefaultDescFont).Height;
                    for (int i = 0; i < SelectedTask.Description.Length; i++)
                    {
                        //TODO: Implement text wrapping
                        txtheight += descTextHeight + 2;
                        float tmp_text_width = gfx.MeasureString(SelectedTask.Description[i], DefaultDescFont).Width;
                        bodyWitdh = tmp_text_width > bodyWitdh ? tmp_text_width : bodyWitdh;
                    }
                    break;
            }


            width = titleWidth > bodyWitdh ? imgwidth + 2 + titleWidth : imgwidth + 2 + bodyWitdh;
            height = txtheight > imgheight ? txtheight : imgheight;

            return new Size(Convert.ToInt32(width), Convert.ToInt32(height));
        }
        /// <summary>
        /// Obtains a task title text according to <see cref="DrawMode"/>
        /// </summary>
        /// <returns></returns>
        private string GetTitle()
        {
            string subjectTitle = TaskHandler.GetSubject(SelectedTask.SubjectID);
            if (subjectTitle != Subject.DefaultMissingSubjectText)
                subjectTitle += " - ";
            else
                subjectTitle = "";
            string title = subjectTitle + SelectedTask.Name;
            if (DrawMode == TaskDrawMode.TasksView && SelectedTask.DueDate != DateTime.MinValue)
                title += " - Due " + SelectedTask.DueDate.ToString("dd/MM");
            return title;
        }
        #endregion
    }
    internal class SubjectControl : ListViewItem
    {
        public Subject SelectedSubject { get; set; }
        public SubjectControl(Subject subject)
        {
            SelectedSubject = subject;
            Text = subject.SubjectName;
        }
    }
    internal class PlanningDayPanel : TableLayoutPanel
    {
        #region Default constructor and variable
        public DateTime SelectedDay;
        public bool IsCancelled = false;
        private DayNote CancelledDay;
        public PlanningDayPanel(DateTime day, TaskHost taskHost)
        {
            SelectedDay = day;
            //Add main container
            ColumnCount = 1; RowCount = 2; Dock = DockStyle.Fill;
            RowStyles.Add(new RowStyle(SizeType.AutoSize));
            RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            //Add top label
            Label lbl = new()
            {
                Text = day.ToString("dd/MMM"),
                AutoSize = true,
                Font = day == DateTime.Today ? new Font(Font, FontStyle.Bold) : Font
            };
            Controls.Add(lbl, 0, 0);

            //Add flowLayoutPanel
            FlowLayoutPanel flp = new() { Dock = DockStyle.Fill, FlowDirection = FlowDirection.TopDown, AutoScroll = true, WrapContents = false };
            Controls.Add(flp, 0, 1);
            flp.SuspendLayout();

            //Check cancelled day
            DayNote? cDay = taskHost.SaveFile.DayNotes.GetObjectByDate(day);

            if (cDay != null)
            {
                CancelledDay = cDay;
                if (cDay.Cancelled)
                {
                    IsCancelled = true;
                    BackColor = Color.Pink;
                    Label cancelLbl = new()
                    {
                        Text = "Cancelled. Reason:\n\n" + cDay.Message,
                        AutoSize = false,
                        Dock = DockStyle.Fill
                    };
                    Controls.Remove(flp);
                    Controls.Add(cancelLbl,0,1);
                    cancelLbl.Click += CancelledDay_Click;
                    Click += CancelledDay_Click;
                }
                else
                {
                    lbl.Text += "\n" + cDay.Message;
                    lbl.Click += CancelledDay_Click;
                }
            }

            //Add tasks
            Task[] dayTasks = taskHost.GetTasksPlannedForDate(day);
            DateTime minDate = HelperFunctions.GetSunday(DateTime.Today);
            foreach (Task task in dayTasks)
            {
                if (IsCancelled || task.ExecDate < minDate)
                {
                    task.ExecDate = null; 
                }
                else
                {
                    TaskControl ctrl = new(taskHost, task) { AutoSize = true, DrawMode = TaskControl.TaskDrawMode.Planner };
                    ctrl.MouseDown += Ctrl_MouseDown;
                    ctrl.MouseUp += Ctrl_MouseUp;
                    ctrl.MouseMove += Ctrl_MouseMove;
                    flp.Controls.Add(ctrl);
                }
            }
            flp.ResumeLayout();
        }

        #endregion
        #region TaskControl event assignments
        private void CancelledDay_Click(object? sender, EventArgs e)
        {
            OnCancelledDayClick(sender);
        }
        private void Ctrl_MouseUp(object? sender, MouseEventArgs e)
        {
            OnControlMouseUp(sender, e);
        }

        private void Ctrl_MouseDown(object? sender, MouseEventArgs e)
        {
            OnControlMouseDown(sender, e);
        }
        private void Ctrl_MouseMove(object? sender, MouseEventArgs e)
        {
            OnControlMouseMove(sender, e);
        }
        #endregion
        #region Event definitions
        public class CancelledDayEventArgs : EventArgs
        {
            public DayNote SelectedDayNote { get; set; }

            public CancelledDayEventArgs(DayNote cancelledDay)
            {
                SelectedDayNote = cancelledDay;
            }
        }

        public delegate void CancelledDayEventHandler(object sender, CancelledDayEventArgs e);
        public event MouseEventHandler ControlMouseDown;
        public event MouseEventHandler ControlMouseUp;
        public event MouseEventHandler ControlMouseMove;
        public event CancelledDayEventHandler CancelledDayClick;
        protected virtual void OnControlMouseDown(object? sender, MouseEventArgs e)
        {
            MouseEventHandler temp = ControlMouseDown;
            if (temp != null)
            {
                temp(sender, e);
            }
        }
        protected virtual void OnControlMouseUp(object? sender, MouseEventArgs e)
        {
            MouseEventHandler temp = ControlMouseUp;
            if (temp != null)
            {
                temp(sender, e);
            }
        }
        protected virtual void OnControlMouseMove(object? sender, MouseEventArgs e)
        {
            MouseEventHandler temp = ControlMouseMove;
            if (temp != null)
            {
                temp(sender, e);
            }
        }
        protected virtual void OnCancelledDayClick(object? sender)
        {
            CancelledDayEventHandler temp = CancelledDayClick;
            if (temp != null)
            {
                temp(sender, new CancelledDayEventArgs(CancelledDay));
            }
        }
        #endregion
    }

    internal class RecentFileListViewItem : ListViewItem
    {
        public string FilePath { get; set; }
    }
    internal class TaskListViewItem : ListViewItem
    {
        public Task Task;
        public TaskListViewItem(Task task)
        {
            Task = task;
            Text = task.Name;
        }
    }

    internal class ScheduleComboBox : ComboBox
    {
        public Schedule ParentSchedule { get; set; }
        public int ScheduleDate { get; set; }
    }

    internal class ScheduleLabel : Label
    {
        private bool _Selected = false;
        public bool Selected { get { return _Selected; } set
            {
                _Selected = value;
                if (_Selected)
                {
                    BackColor = SystemColors.Highlight;
                    ForeColor = Color.White;
                }
                else
                {
                    BackColor = SystemColors.Control;
                    ForeColor = Color.Black;
                }
            }
        }
        public ScheduleLabelList ParentList;
        public Schedule SelectedSchedule;
        public ScheduleLabel(ScheduleLabelList parent, Schedule schedule)
        {
            ParentList = parent;
            AutoSize = true;
            Anchor = AnchorStyles.None;
            SelectedSchedule = schedule;
            UpdateText();
            Click += ScheduleLabel_Click;
        }

        public void UpdateText()
        {
            Text = SelectedSchedule.StartTime.ToString() + " - " + SelectedSchedule.EndTime.ToString();
        }

        private void ScheduleLabel_Click(object? sender, EventArgs e)
        {
            ParentList.Select(this);
        }
    }
    internal class ScheduleLabelList : List<ScheduleLabel>
    {
        public ScheduleLabel? SelectedLabel;
        public void Select(ScheduleLabel lbl)
        {
            SelectedLabel = lbl;

            for (int i = 0; i < this.Count; i++)
            {
                this[i].Selected = false;
            }
            SelectedLabel.Selected = true;
            OnSelected();
        }

        public event EventHandler Selected;

        protected internal void OnSelected()
        {
            EventHandler temp = Selected;
            if (temp != null)
            {
                temp(this,EventArgs.Empty);
            }
        }
    }
}
