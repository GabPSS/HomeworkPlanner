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
    public partial class ScheduleForm : Form
    {
        TaskHost THost;
        public ScheduleForm(TaskHost tHost)
        {
            InitializeComponent();
            THost = tHost;
            UpdateSchedules();
        }

        public void UpdateSchedules()
        {
            AddColumns();
            AddRows();

            
        }

        public void AddRows()
        {
            for (int i = 0; i < THost.SaveFile.Schedules.Items.Count; i++)
            {
                //THost.SaveFile.Schedules.Items[i].Subjects.Cast<>;
                DataGridViewRow row = new();
                dataGridView1.Rows.Add(row);
                for (int x = 0; x < THost.SaveFile.Schedules.Items[i].Subjects.Count; x++)
                {
                    DataGridViewComboBoxCell cell = (DataGridViewComboBoxCell)row.Cells[x];
                    cell.Items.AddRange(THost.SaveFile.Subjects.Items.ToArray());
                    //cell.Value = 1;
                    //cell.Items.Add("Hello");
                    //cell.Value = "Hello";
                    var subjectID = THost.SaveFile.Schedules.Items[i].Subjects[x];
                    if (subjectID != null)
                    {
                        //cell.combo

                        
                        var sub = THost.GetSubjectById(subjectID.Value);
                        cell.Value = sub;
                    }
                    //row.Cells.Add(cell);
                }
            }
        }

        public void AddColumns()
        {
            //dataGridView1.Columns.Add("time", "Schedules");
            var daysData = (int)THost.SaveFile.Schedules.DaysToDisplay;
            DateTime refDate = HelperFunctions.GetSunday(DateTime.Today.Date).AddDays(6);
            List<DateTime> datesList = new();
            for (int i = 64; i >= 1; i /= 2)
            {
                if (daysData - i >= 0)
                {
                    datesList.Add(refDate);
                    daysData -= i;
                }
                refDate = refDate.Subtract(TimeSpan.FromDays(1));
            }
            datesList.Reverse();
            for (int i = 0; i < datesList.Count; i++)
            {
                DataGridViewComboBoxColumn col = new();
                col.HeaderText = datesList[i].DayOfWeek.ToString();
                
                //col.Name = ((int)datesList[i].DayOfWeek).ToString();
                dataGridView1.Columns.Add(col);
            }            
        }
    }
}
