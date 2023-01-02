using System.ComponentModel;
using System.Text.Json;
using HomeworkPlanner.TaskControls;

namespace HomeworkPlanner
{
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
    
        public void UnscheduleAllTasks()
        {
            for (int i = 0; i < SaveFile.Tasks.Items.Count; i++)
            {
                SaveFile.Tasks.Items[i].ExecDate = null;
            }
        }

        public static Task[] SortTasksByDueDate(Task[] tasks)
        {
            List<Task> tasksList = tasks.ToList() ;
            tasksList.Sort(CompareTasksByDueDate);
            return tasksList.ToArray();
        }

        private static int CompareTasksByDueDate(Task x, Task y)
        {
            return x.DueDate == y.DueDate ? 0 : x.DueDate > y.DueDate ? 1 : -1;
        }

        public void RemoveTasksPriorTo(DateTime date)
        {
            SaveFile.Tasks.Items.RemoveAll(x => x.IsCompleted && x.DateCompleted < date);
            SaveFile.Tasks.Items.RemoveAll(x => x.IsCompleted && x.IsScheduled && x.ExecDate < date);
        }
    }
    public class SaveFile
    {
        public SaveFile()
        {
            Tasks = new();
            Subjects = new();
            CancelledDays = new();
            Settings = new();
        }
        public TaskList Tasks { get; set; }
        public SubjectList Subjects { get; set; }
        public CancelledDayList CancelledDays { get; set; }
        public SaveSettings Settings { get; set; }

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
    #region List objects
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
    public class CancelledDayList : List<CancelledDay>
    {
        public CancelledDay? GetObjectByDate(DateTime date)
        {
            CancelledDay? output = null;
            for (int i = 0; i < Count; i++)
            {
                output = this[i].Date.Date == date.Date ? this[i] : output;
            }
            return output;
        }
    }
    #endregion
    #region Main objects
    public class Task: ICloneable
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
                if (DateCompleted == null)
                {
                    DateCompleted = value ? DateTime.Today : null;
                }
                else
                {
                    DateCompleted = !value ? null : DateCompleted;
                }
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
                else if (IsScheduled && IsImportant || IsScheduled && DueDate <= DateTime.Today.AddDays(1))
                {
                    return Properties.Resources.Important;
                }
                else
                {
                    return IsImportant || DueDate <= DateTime.Today.AddDays(1) ? Properties.Resources.NewImportant : (Image)(IsScheduled ? Properties.Resources.Scheduled : Properties.Resources.New);
                }
            }
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
    public class CancelledDay
    {
        public DateTime Date { get; set; }
        public string Message { get; set; }
    }
    #endregion
    #region Settings objects
    public enum DaysToInclude { Sunday = 1, Monday = 2, Tuesday = 4, Wednesday = 8, Thursday = 16, Friday = 32, Saturday = 64 }
    public class SaveSettings
    {
        public int FutureWeeks { get; set; } = 2;
        public DaysToInclude DaysToDisplay { get; set; } = DaysToInclude.Monday | DaysToInclude.Tuesday | DaysToInclude.Wednesday | DaysToInclude.Thursday | DaysToInclude.Friday;
        public bool DisplayPreviousTasks { get; set; } = false;
    }
    #endregion
}
