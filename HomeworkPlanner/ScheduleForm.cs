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
                var item = THost.SaveFile.Schedules.Items[i];

                tableLayoutPanel2.RowCount++;
                tableLayoutPanel2.RowStyles.Add(new(SizeType.AutoSize));
                var str = item.StartTime.ToString() + " - " + item.EndTime.ToString();
                Label lbl = new()
                {
                    Text = str,
                    AutoSize = true,
                    Anchor = AnchorStyles.None
                };
                tableLayoutPanel2.Controls.Add(lbl,0,i+1);

                for (int x = 0; x < item.Subjects.Count; x++)
                {
                    var cmbx = new ComboBox()
                    {
                        DropDownStyle = ComboBoxStyle.DropDownList
                    };
                    cmbx.Items.Add("(None)");
                    cmbx.SelectedIndex = 0;
                    cmbx.Items.AddRange(THost.SaveFile.Subjects.Items.ToArray());
                    var subjectID = item.Subjects[x];
                    if (subjectID != null)
                    {
                        var sub = THost.GetSubjectById(subjectID.Value);
                        cmbx.SelectedIndex = cmbx.Items.IndexOf(sub);
                    }
                    tableLayoutPanel2.Controls.Add(cmbx,x+1,i+1);
                }
            }
        }

        public void AddColumns()
        {
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
            tableLayoutPanel2.ColumnCount = datesList.Count + 1;
            for (int i = 0; i < datesList.Count; i++)
            {
                tableLayoutPanel2.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
                Label lbl = new()
                {
                    Text = datesList[i].DayOfWeek.ToString(),
                };
                tableLayoutPanel2.Controls.Add(lbl, i + 1,0);
            }            
        }
    }
}
