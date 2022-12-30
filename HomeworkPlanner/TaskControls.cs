﻿using System;
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
        public Font DefaultTitleFont { get; set; } = new Font(FontFamily.GenericSansSerif, 10, FontStyle.Bold);
        public Font DefaultDueFont { get; set; } = new Font(FontFamily.GenericSansSerif, 10);
        public Font DefaultDescFont { get; set; } = new Font(FontFamily.GenericSansSerif, 8);
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
            gfx.Clear(BackColor);
            gfx.DrawImage(Icon, 0, 0, 32, 32);

            SizeF TitleMeasurement = gfx.MeasureString(GetTitle(), DefaultTitleFont);
            gfx.DrawString(GetTitle(), DefaultTitleFont, DrawingBrush, 34, 0);
            float text_y = TitleMeasurement.Height + 3;
            float text_x = 34;
            switch (DrawMode)
            {
                case TaskDrawMode.Planner:
                    gfx.DrawString("Due: " + SelectedTask.DueDate.ToString("dd/MM"), DefaultDueFont, DrawingBrush, text_x, text_y);
                    break;
                case TaskDrawMode.TasksView:
                    //List<SizeF> Items = new List<SizeF>();
                    float descTextHeight = gfx.MeasureString("This is a test string", DefaultDescFont).Height;
                    for (int i = 0; i < SelectedTask.Description.Length; i++)
                    {
                        //TODO: Implement text wrapping
                        gfx.DrawString(SelectedTask.Description[i], DefaultDescFont, DrawingBrush, text_x, text_y);
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

            imgwidth = 32;
            imgheight = 32;

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
            if (DrawMode == TaskDrawMode.TasksView)
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
                Text = day.ToString("dd"),
                Dock = DockStyle.Fill
            };
            Controls.Add(lbl, 0, 0);

            //Add flowLayoutPanel
            FlowLayoutPanel flp = new() { Dock = DockStyle.Fill, FlowDirection = FlowDirection.TopDown, AutoScroll = true, WrapContents = false };
            Controls.Add(flp, 0, 1);

            //Add tasks
            Task[] dayTasks = taskHost.GetTasksPlannedForDate(day);
            foreach (Task task in dayTasks)
            {
                TaskControl ctrl = new(taskHost, task) { AutoSize = true, DrawMode = TaskControl.TaskDrawMode.Planner };
                ctrl.MouseDown += Ctrl_MouseDown;
                ctrl.MouseUp += Ctrl_MouseUp;
                flp.Controls.Add(ctrl);
            }
        }
        #endregion
        #region TaskControl event assignments
        private void Ctrl_MouseUp(object? sender, MouseEventArgs e)
        {
            OnControlMouseUp(sender, e);
        }

        private void Ctrl_MouseDown(object? sender, MouseEventArgs e)
        {
            OnControlMouseDown(sender, e);
        }
        #endregion
        #region Event definitions
        public event MouseEventHandler ControlMouseDown;
        public event MouseEventHandler ControlMouseUp;
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
        #endregion
    }
}