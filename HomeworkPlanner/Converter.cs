using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace HomeworkPlanner
{
    public class Converter
    {
        public static NewTaskSystem.NewSaveFile ConvertToNewTaskSystem(SaveFile oldFile)
        {
            NewTaskSystem.NewSaveFile newFile = new NewTaskSystem.NewSaveFile();
            newFile.DayNotes = oldFile.DayNotes;
            newFile.Subjects = oldFile.Subjects;
            newFile.Schedules = oldFile.Schedules;
            newFile.Settings = oldFile.Settings;

            //Converting old TaskList
            newFile.Tasks.LastIndex = oldFile.Tasks.LastIndex;

            for (int i = 0; i < oldFile.Tasks.Items.Count; i++)
            {
                //Converting old tasks to new task format
                NewTaskSystem.NewTask newTask = new NewTaskSystem.NewTask();
                newTask.Name = oldFile.Tasks.Items[i].Name;
                newTask.IsImportant = oldFile.Tasks.Items[i].IsImportant;
                newTask.TaskID = oldFile.Tasks.Items[i].TaskID;
                newTask.SubjectID = oldFile.Tasks.Items[i].SubjectID;
                newTask.DueDate = oldFile.Tasks.Items[i].DueDate;
                newTask.ExecDate = oldFile.Tasks.Items[i].ExecDate;
                newTask.DateCompleted = oldFile.Tasks.Items[i].DateCompleted;

                newTask.Description = "";
                for (int ix = 0; ix < oldFile.Tasks.Items[i].Description.Length; ix++)
                {
                    newTask.Description += oldFile.Tasks.Items[i].Description[ix];
                    if (ix != oldFile.Tasks.Items[i].Description.Length - 1)
                    {
                        newTask.Description += "\n";
                    }
                }

                newFile.Tasks.Items.Add(newTask);
            }

            return newFile;
        }

        public static string GetNewTaskSystemJSON(SaveFile oldFile)
        {
            return JsonSerializer.Serialize<NewTaskSystem.NewSaveFile>(ConvertToNewTaskSystem(oldFile));
        }
    }

    public class NewTaskSystem
    {
        public class NewSaveFile : SaveFile
        {
            public new NewTaskList Tasks { get; set; } = new NewTaskList();
        }

        public class NewTaskList : TaskList
        {
            public new List<NewTask> Items { get; set; } = new();
        }

        public class NewTask : Task
        {
            public new string Description { get; set; } = "";
        }
    }
}
