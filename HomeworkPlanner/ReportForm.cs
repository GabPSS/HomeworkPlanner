using HomeworkPlanner.TaskControls;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace HomeworkPlanner
{
    public partial class ReportForm : Form
    {
        TaskHost TaskHost;
        List<(string Group, List<Task> Tasks)> Report;
        public ReportForm(TaskHost taskHost)
        {
            InitializeComponent();
            TaskHost = taskHost;
            Report = taskHost.GenerateReport();
            UpdateReportViews();
        }

        public void UpdateReportViews()
        {
            //Clear everything
            listView1.Items.Clear();
            listView1.Groups.Clear();

            for (int i = 0; i < Report.Count; i++)
            {
                ListViewGroup group = new(Report[i].Group);
                listView1.Groups.Add(group);
                for (int x = 0; x < Report[i].Tasks.Count; x++)
                {
                    TaskListViewItem item = new(Report[i].Tasks[x]);
                    item.Group = group;
                    item.SubItems.Add(TaskHost.GetSubject(item.Task.SubjectID));
                    item.SubItems.Add(item.Task.ExecDate == null ? "None" : item.Task.ExecDate.Value.ToShortDateString());
                    item.SubItems.Add(item.Task.IsImportant.ToString());
                    listView1.Items.Add(item);
                }
            }
        }
    }
}
