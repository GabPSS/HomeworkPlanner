using System.ComponentModel;
using System.Text.Json;

namespace HomeworkPlanner
{
    public class SaveFile
    {
        public SaveFile()
        {
            Tasks = new();
            Subjects = new();
        }
        public TaskList Tasks { get; set; }
        public SubjectList Subjects { get; set; }

        public static SaveFile FromJSON(string JSON)
        {
            SaveFile? output = JsonSerializer.Deserialize<SaveFile>(JSON);
            if (output is null)
                throw new JsonException();
            return output;
        }

        public string MakeJSON()
        {
            return JsonSerializer.Serialize(this);
        }
    }

    public class Task : ICloneable
    {
        public int TaskID { get; set; } = -1;
        public int SubjectID { get; set; } = -1;
        public string Name { get; set; }
        public DateTime DueDate { get; set; } = DateTime.Today;
        public string[] Description { get; set; } = Array.Empty<string>();
        public DateTime? ExecDate { get; set; }

        public DateTime? DateCompleted { get; set; }
        public bool IsCompleted
        {
            get
            {
                return DateCompleted != null;
            }
            set
            {
                DateCompleted = value ? DateTime.Today : null;
            }
        }
        public bool IsImportant { get; set; }

        public bool IsScheduled
        {
            get
            {
                return ExecDate != null;
            }
        }
        public bool IsOverdue
        {
            get
            {
                return !IsCompleted && (DueDate < DateTime.Today);
            }
        }

        public object Clone()
        {
            return MemberwiseClone();
        }

        public Image GetIcon()
        {
            if (IsCompleted)
            {
                return Properties.Resources.Done;
            }
            else
            {
                if (IsOverdue)
                {
                    return Properties.Resources.Overdue;
                }
                else if (IsScheduled && IsImportant)
                {
                    return Properties.Resources.Important;
                }
                else
                {
                    return IsImportant ? Properties.Resources.NewImportant : (Image)(IsScheduled ? Properties.Resources.Scheduled : Properties.Resources.New);
                }
            }
        }
    }

    public class TaskList
    {
        public int LastIndex { get; set; } = -1;
        public List<Task> Items { get; set; } = new();

        public void Add(Task item)
        {
            int newIndex = LastIndex + 1;
            item.TaskID = newIndex;
            Items.Add(item);
            LastIndex = newIndex;
        }
    }

    public class Subject
    {
        public int SubjectID { get; set; }
        public string SubjectName { get; set; }
        public const string DefaultMissingSubjectText = "(No subject)";
        public Subject(int subjectID, string subjectName)
        {
            SubjectID = subjectID;
            SubjectName = subjectName;
        }

        public override string ToString()
        {
            return SubjectName;
        }
    }

    public class SubjectList
    {
        public int LastIndex { get; set; } = -1;
        public List<Subject> Items { get; set; } = new();

        public int Add(string subject)
        {
            //TODO: Check if ID exists
            int newIndex = LastIndex + 1;
            Items.Add(new Subject(newIndex, subject));
            LastIndex = newIndex;
            return newIndex;
        }
    }

    public class TaskHost
    {
        public TaskHost(SaveFile saveFile, string? saveFilePath = null)
        {
            SaveFile = saveFile;
            SaveFilePath = saveFilePath;
        }
        public string? SaveFilePath { get; set; }
        public SaveFile SaveFile { get; set; }
        public string GetSubject(int id)
        {
            string output = Subject.DefaultMissingSubjectText;
            for (int i = 0; i < SaveFile.Subjects.Items.Count; i++)
            {
                if (SaveFile.Subjects.Items[i].SubjectID == id)
                {
                    output = SaveFile.Subjects.Items[i].SubjectName;
                }
            }
            return output;
        }

        /// <summary>
        /// Get all tasks planned for a certain date
        /// </summary>
        /// <param name="date">The date to look up for</param>
        /// <returns>An array containing all tasks planned for the given date parameter</returns>
        public Task[] GetTasksPlannedForDate(DateTime date)
        {
            List<Task> tasks = new();
            for (int i = 0; i < SaveFile.Tasks.Items.Count; i++)
            {
                if (SaveFile.Tasks.Items[i].ExecDate != null)
                {
                    if (SaveFile.Tasks.Items[i].ExecDate == date)
                    {
                        tasks.Add(SaveFile.Tasks.Items[i]);
                    }
                }
            }
            return tasks.ToArray();
        }

        public static (Task[] completed, Task[] remaining) FilterTasks(Task[] tasks)
        {
            List<Task> completedTasks = new();
            List<Task> remainingTasks = tasks.ToList();
            for (int i = 0; i < tasks.Length;i++)
            {
                if (tasks[i].IsCompleted)
                {
                    completedTasks.Add(tasks[i]);
                    remainingTasks.Remove(tasks[i]);
                }
            }
            return (completedTasks.ToArray(),remainingTasks.ToArray());
        }

        public int GetTaskIndexById(int id)
        {
            for (int i = 0; i < SaveFile.Tasks.Items.Count; i++)
            {
                if (SaveFile.Tasks.Items[i].TaskID== id)
                {
                    return i;
                }
            }
            return -1;
        }
    }

    public class TaskControl : Control
    {
        public enum TaskDrawMode { Planner, TasksView }

        public TaskDrawMode DrawMode { get; set; } = TaskDrawMode.TasksView;
        public TaskHost TaskHandler { get; set; }
        public Task SelectedTask { get; set; }
        public bool IsDragging = false;
        public Font DefaultTitleFont { get; set; } = new Font(FontFamily.GenericSansSerif, 10, FontStyle.Bold);
        public Font DefaultDueFont { get; set; } = new Font(FontFamily.GenericSansSerif, 10);
        public Font DefaultDescFont { get; set; } = new Font(FontFamily.GenericSansSerif, 8);

        private Image Icon { get { return SelectedTask.GetIcon(); } }
        private Brush DrawingBrush { get { return new SolidBrush(ForeColor); } }
        public TaskControl(TaskHost taskHandler, Task selectedTask)
        {
            TaskHandler = taskHandler;
            SelectedTask = selectedTask;
        }

        /// <summary>
        /// Defines if the control should be sized automatically
        /// </summary>
        [DefaultValue(true)]
        public override bool AutoSize { get => base.AutoSize; set => base.AutoSize = value; } 
        protected override void OnPaint(PaintEventArgs e)
        {
            DrawControl(e.Graphics);
        }

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

        public override Size GetPreferredSize(Size proposedSize)
        {
            return MeasureControl(CreateGraphics());
        }
    }

    public class SubjectControl : ListViewItem
    {
        public Subject SelectedSubject { get; set; }
        
        public SubjectControl(Subject subject)
        {
            SelectedSubject = subject;
            Text = subject.SubjectName;
        }
    }
}
