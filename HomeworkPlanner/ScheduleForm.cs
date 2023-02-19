using HomeworkPlanner.TaskControls;

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
                //Set a schedule variable
                var schedule = THost.SaveFile.Schedules.Items[i];

                //Add row and label to TLP2
                tableLayoutPanel2.RowCount++;
                tableLayoutPanel2.RowStyles.Add(new(SizeType.AutoSize));
                var str = schedule.StartTime.ToString() + " - " + schedule.EndTime.ToString();
                Label lbl = new()
                {
                    Text = str,
                    AutoSize = true,
                    Anchor = AnchorStyles.None
                };
                tableLayoutPanel2.Controls.Add(lbl, 0, i + 1);

                for (int date = 0; date < schedule.Subjects.Count; date++)
                {
                    //Add ScheduleComboBox
                    var cmbx = new ScheduleComboBox()
                    {
                        DropDownStyle = ComboBoxStyle.DropDownList
                    };
                    cmbx.Items.Add("(None)");
                    cmbx.SelectedIndex = 0;
                    cmbx.Items.AddRange(THost.SaveFile.Subjects.Items.ToArray());
                    cmbx.FlatStyle = FlatStyle.Flat;
                    cmbx.BackColor = Color.White;
                    var subjectID = schedule.Subjects[date];
                    if (subjectID != null)
                    {
                        var sub = THost.GetSubjectById(subjectID.Value);
                        cmbx.SelectedIndex = cmbx.Items.IndexOf(sub);
                        cmbx.BackColor = Color.FromArgb(sub.SubjectColor);
                    }
                    cmbx.ParentSchedule = schedule;
                    cmbx.ScheduleDate = date;
                    cmbx.SelectedValueChanged += Cmbx_SelectedValueChanged;
                    tableLayoutPanel2.Controls.Add(cmbx, date + 1, i + 1);
                }
            }
        }

        private void Cmbx_SelectedValueChanged(object? sender, EventArgs e)
        {
            if (sender is ScheduleComboBox cmbx)
            {
                int? newValue = null;
                cmbx.BackColor = Color.White;
                if (cmbx.Items[cmbx.SelectedIndex] is Subject s)
                {
                    newValue = s.SubjectID;
                    cmbx.BackColor = Color.FromArgb(THost.GetSubjectById(newValue.Value).SubjectColor);
                }
                cmbx.ParentSchedule.Subjects[cmbx.ScheduleDate] = newValue;
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
                tableLayoutPanel2.Controls.Add(lbl, i + 1, 0);
            }
        }
    }
}
