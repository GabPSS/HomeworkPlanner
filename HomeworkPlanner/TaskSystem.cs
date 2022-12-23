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

        public static SaveFile? FromJSON(string JSON)
        {
            return JsonSerializer.Deserialize<SaveFile>(JSON);
        }

        public string MakeJSON()
        {
            return JsonSerializer.Serialize(this);
        }
    }

    public class Task
    {
        public int TaskID { get; set; } = -1;
        public int? SubjectID { get; set; } = -1;
        public string Name { get; set; }
        public DateTime DueDate { get; set; }
        public string[] Description { get; set; }
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
                return DueDate < DateTime.Today;
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
            item.TaskID = item.TaskID == -1 ? newIndex : item.TaskID;
            Items.Add(item);
            LastIndex = newIndex;
        }
    }

    public class Subject
    {
        public int SubjectID { get; set; }
        public string SubjectName { get; set; }

        public Subject(int subjectID, string subjectName)
        {
            SubjectID = subjectID;
            SubjectName = subjectName;
        }
    }

    public class SubjectList
    {
        public int LastIndex { get; set; } = -1;
        public List<Subject> Items { get; set; } = new();

        public int Add(string subject)
        {
            int newIndex = LastIndex + 1;
            Items.Add(new Subject(newIndex, subject));
            LastIndex = newIndex;
            return newIndex;
        }
    }
}
