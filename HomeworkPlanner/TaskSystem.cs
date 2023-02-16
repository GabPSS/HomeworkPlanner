using System.ComponentModel;
using System.Text.Json;
using HomeworkPlanner.TaskControls;

namespace HomeworkPlanner
{
    public enum SortMethod { None = -1, DueDate = 0, ID = 1, Alphabetically = 2, Status = 3, Subject = 4, ExecDate = 5, DateCompleted }
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
    
        public void UnscheduleAllTasks(bool excludeCompleted = false)
        {
            for (int i = 0; i < SaveFile.Tasks.Items.Count; i++)
            {
                // Check if item isn't completed. Then checks if excludeCompleted is false.
                // This makes for the effect where when excludeCompleted is false, everything is unscheduled
                // However, when it's true, only the items that are not completed are unscheduled
                if (!SaveFile.Tasks.Items[i].IsCompleted || !excludeCompleted)
                {
                    SaveFile.Tasks.Items[i].ExecDate = null;
                }
            }
        }
        public static List<Task> SortTasks(SortMethod sortMethod, List<Task> tasks)
        {
            switch (sortMethod)
            {
                case SortMethod.DueDate:
                    //tasks.Sort((Task x, Task y) => { return x.DueDate == y.DueDate ? 0 : x.DueDate > y.DueDate ? 1 : -1; });
                    tasks.Sort((Task x, Task y) => { return x.DueDate.CompareTo(y.DueDate); });
                    break;
                case SortMethod.ID:
                    tasks.Sort((Task x, Task y) => { return x.TaskID - y.TaskID; });
                    break;
                case SortMethod.Alphabetically:
                    tasks.Sort((Task x, Task y) => { return x.Name.CompareTo(y.Name); });
                    break;
                case SortMethod.Status:
                    tasks.Sort((Task x, Task y) => { return x.GetStatus() - y.GetStatus(); });
                    break;
                case SortMethod.Subject:
                    tasks.Sort((Task x, Task y) => { return x.SubjectID - y.SubjectID; });
                    break;
                case SortMethod.ExecDate:
                    tasks.Sort((Task x, Task y) => { return y.ExecDate.HasValue ? (x.ExecDate.HasValue ? x.ExecDate.Value.CompareTo(y.ExecDate.Value) : 1) : -1; });
                    break;
                case SortMethod.DateCompleted:
                    tasks.Sort((Task x, Task y) => { return y.DateCompleted.HasValue ? (x.DateCompleted.HasValue ? x.DateCompleted.Value.CompareTo(y.DateCompleted.Value) : 1) : -1; });
                    break;
                default:
                    break;
            }
            return tasks;
        }

        public void RemoveCompletedTasks() => SaveFile.Tasks.Items.RemoveAll(x => x.IsCompleted);

        public void RemoveAllTasks()
        {
            SaveFile.Tasks = new();
        }

        public void RemoveTasksPriorTo(DateTime date)
        {
            SaveFile.Tasks.Items.RemoveAll(x => x.IsCompleted && x.DateCompleted < date);
            SaveFile.Tasks.Items.RemoveAll(x => x.IsCompleted && x.IsScheduled && x.ExecDate < date);
        }

        public void ResetTaskIDs()
        {
            int i;
            for (i = 0; i < SaveFile.Tasks.Items.Count; i++)
            {
                SaveFile.Tasks.Items[i].TaskID = i;
            }
            SaveFile.Tasks.LastIndex = i-1;
        }

        public void ResetSubjectIDs()
        {
            int new_sid;
            for (new_sid = 0; new_sid < SaveFile.Subjects.Items.Count; new_sid++)
            {
                int old_sid = SaveFile.Subjects.Items[new_sid].SubjectID;

                for (int i = 0; i < SaveFile.Tasks.Items.Count; i++)
                {
                    if (SaveFile.Tasks.Items[i].SubjectID == old_sid)
                    {
                        SaveFile.Tasks.Items[i].SubjectID = new_sid;
                    }
                }

                SaveFile.Subjects.Items[new_sid].SubjectID = new_sid;
            }

            SaveFile.Subjects.LastIndex = new_sid-1;
        }

        public void Repair()
        {
            RemoveTasksPriorTo(DateTime.Today);
            RemoveCancelledDaysPriorTo(DateTime.Today);
            ResetTaskIDs();
            ResetSubjectIDs();
        }

        private void RemoveCancelledDaysPriorTo(DateTime date)
        {
            SaveFile.CancelledDays.RemoveAll(x => x.Date < date);
        }

        public List<(string Group, List<Task> Tasks)> GenerateReport()
        {
            List<(string Group, List<Task> Tasks)> output = new();
            List<Task> sortedCompletedTasks = SortTasks(SortMethod.DateCompleted, FilterTasks(SaveFile.Tasks.Items.ToArray()).completed.ToList());
            List<DateTime> Dates = new();
            for (int i = 0; i < sortedCompletedTasks.Count; i++)
            {
                if (sortedCompletedTasks[i].DateCompleted != null && !Dates.Contains(sortedCompletedTasks[i].DateCompleted.Value))
                {
                    Dates.Add(sortedCompletedTasks[i].DateCompleted.Value);
                }
            }
            for (int i = 0; i < Dates.Count; i++)
            {
                List<Task> tasks = new();
                for (int x = 0; x < sortedCompletedTasks.Count; x++)
                {
                    if (sortedCompletedTasks[x].DateCompleted != null && sortedCompletedTasks[x].DateCompleted == Dates[i])
                    {
                        tasks.Add(sortedCompletedTasks[x]);
                        sortedCompletedTasks.RemoveAt(x);
                        x--;
                    }
                }
                output.Add((Dates[i].ToShortDateString(), tasks));
            }
            if (sortedCompletedTasks.Count > 0)
            {
                output.Add(("Unknown", sortedCompletedTasks));
            }
            return output;
        }
    }
    public class SaveFile
    {
        public SaveFile()
        {
            Tasks = new();
            Subjects = new();
            Schedules = new();
            CancelledDays = new();
            Settings = new();
        }
        public TaskList Tasks { get; set; }
        public SubjectList Subjects { get; set; }
        public ScheduleList Schedules { get; set; }
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

        /// <summary>
        /// Adds a task to Items collection reassigning the ID appropriately
        /// </summary>
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
    public class ScheduleList
    {
        public DaysToInclude DaysToDisplay { get; set; } = DaysToInclude.Monday | DaysToInclude.Tuesday | DaysToInclude.Wednesday | DaysToInclude.Thursday | DaysToInclude.Friday;
        public List<Schedule> Items { get; set; } = new();
    }
    #endregion
    #region Main objects
    public class Task: ICloneable
    {
        public const string UntitledTaskText = "Untitled task";
        public enum TaskStatus { Overdue = -10, None = 0, Scheduled = 10, ImportantUnscheduled = 20, ImportantScheduled = 30, Completed = 70 }
        public int TaskID { get; set; } = -1;
        public int SubjectID { get; set; } = -1;
        public string Name { get; set; } = UntitledTaskText;
        public DateTime DueDate { get; set; } = DateTime.MinValue;
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
                return !IsCompleted && (DueDate < DateTime.Today) && DueDate != DateTime.MinValue;
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

        public TaskStatus GetStatus()
        {
            int status = 0;
            if (IsOverdue)
            {
                status = -10;
            }
            else if (IsCompleted)
            {
                status = 70;
            }
            else
            {
                status = IsScheduled ? status + 10 : status;
                status = IsImportant ? status + 20 : status;
            }

            return (TaskStatus)status;
        }
        public override string ToString()
        {
            return Name;
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

    public class Schedule
    {
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public List<int?> Subjects { get; set; } = new();
    }
    #endregion
    #region Settings objects
    public enum DaysToInclude { Sunday = 1, Monday = 2, Tuesday = 4, Wednesday = 8, Thursday = 16, Friday = 32, Saturday = 64 }
    public class SaveSettings
    {
        public int FutureWeeks { get; set; } = 2;
        public DaysToInclude DaysToDisplay { get; set; } = DaysToInclude.Monday | DaysToInclude.Tuesday | DaysToInclude.Wednesday | DaysToInclude.Thursday | DaysToInclude.Friday;
        public bool DisplayPreviousTasks { get; set; } = false;
        public SortMethod SortMethod { get; set; } = SortMethod.DueDate;
    }
    #endregion
}
