using HomeworkPlanner.TaskControls;
using System.Text.RegularExpressions;

namespace HomeworkPlanner
{
    public partial class ScheduleForm : Form
    {
        TaskHost THost;
        List<int> DaysOfWeek;
        ScheduleLabelList ScheduleLabels;
        public ScheduleForm(TaskHost tHost)
        {
            InitializeComponent();
            THost = tHost;
            UpdateSchedules();
            Days = new() { checkBox1, checkBox2, checkBox3, checkBox4, checkBox5, checkBox6, checkBox7 };
            UpdateCheckboxes();
        }

        private void ScheduleLabels_Selected(object? sender, EventArgs e)
        {
            button1.Enabled = true;
            button2.Enabled = true;
        }

        public void UpdateCheckboxes()
        {
            List<int> daysToInclude = HelperFunctions.GetDaysIncluded(THost.SaveFile.Schedules.DaysToDisplay);
            for (int i = 0; i < Days.Count; i++)
            {
                if (daysToInclude.Contains(i))
                {
                    Days[i].Checked = true;
                }
            }
        }
        public void UpdateSchedules()
        {
            ScheduleLabels = new();
            ScheduleLabels.Selected += ScheduleLabels_Selected;
            DaysOfWeek = new();
            ResetTLP();
            AddColumns();
            AddRows();

            if (tableLayoutPanel2.ColumnCount == 1 && tableLayoutPanel2.RowCount == 1)
            {
                TableLabel.Text = "No schedules created";
            }
            else
            {
                TableLabel.Text = "Schedules";
            }
        }

        public void ResetTLP()
        {
            tableLayoutPanel2.Controls.Clear();

            tableLayoutPanel2.RowCount = 1;
            tableLayoutPanel2.RowStyles.Clear();
            tableLayoutPanel2.RowStyles.Add(new(SizeType.Absolute, 20));
            tableLayoutPanel2.ColumnCount = 1;
            tableLayoutPanel2.ColumnStyles.Clear();
            tableLayoutPanel2.ColumnStyles.Add(new(SizeType.AutoSize));
            tableLayoutPanel2.Controls.Add(TableLabel, 0, 0);
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
                ScheduleLabel lbl = new(ScheduleLabels,schedule)
                {
                    Text = str,
                    AutoSize = true,
                    Anchor = AnchorStyles.None
                };
                ScheduleLabels.Add(lbl);
                tableLayoutPanel2.Controls.Add(lbl, 0, i + 1);

                //Loop through days of week
                int col = 0;
                for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++)
                {
                    if (DaysOfWeek.Contains(dayOfWeek))
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
                        var subjectID = schedule.Subjects[dayOfWeek];
                        if (subjectID != null)
                        {
                            var sub = THost.GetSubjectById(subjectID.Value);
                            cmbx.SelectedIndex = cmbx.Items.IndexOf(sub);
                            cmbx.BackColor = Color.FromArgb(sub.SubjectColor);
                        }
                        cmbx.ParentSchedule = schedule;
                        cmbx.ScheduleDate = dayOfWeek;
                        cmbx.SelectedValueChanged += Cmbx_SelectedValueChanged;
                        tableLayoutPanel2.Controls.Add(cmbx, col + 1, i + 1);
                        col++;
                    }
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
            List<int> daysToInclude = HelperFunctions.GetDaysIncluded(THost.SaveFile.Schedules.DaysToDisplay);
            tableLayoutPanel2.ColumnCount = daysToInclude.Count + 1;
            for (int i = 0; i < daysToInclude.Count; i++)
            {
                tableLayoutPanel2.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
                Label lbl = new()
                {
                    AutoSize = true,
                    Text = ((DayOfWeek)daysToInclude[i]).ToString(),
                    Anchor = AnchorStyles.None
                };
                tableLayoutPanel2.Controls.Add(lbl, i + 1, 0);
                DaysOfWeek.Add(daysToInclude[i]);
            }
        }

        private List<CheckBox> Days;
        public void ToggleDate(object? sender, EventArgs e)
        {
            if (sender is CheckBox c)
            {
                if (Days.Contains(c))
                {
                    int dayOfWeek = Days.IndexOf(c);
                    THost.ToggleDayOfWeek(dayOfWeek, c.Checked);
                    UpdateSchedules();
                }
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            var form = new ScheduleMgmtForm() { Schedule = ScheduleLabels.SelectedLabel.SelectedSchedule };
            if (form.ShowDialog() == DialogResult.OK)
            {
                ScheduleLabels.SelectedLabel.SelectedSchedule.StartTime = form.NewStartTime;
                ScheduleLabels.SelectedLabel.SelectedSchedule.EndTime = form.NewEndTime;
                ScheduleLabels.SelectedLabel.UpdateText();
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            //Add a schedule
            var form = new ScheduleMgmtForm() { Text = "Add schedule"};
            if (form.ShowDialog() == DialogResult.OK)
            {
                Schedule schedule = new()
                {
                    StartTime = form.NewStartTime,
                    EndTime = form.NewEndTime
                };
                THost.SaveFile.Schedules.Items.Add(schedule);
                UpdateSchedules();
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            THost.SaveFile.Schedules.Items.Remove(ScheduleLabels.SelectedLabel.SelectedSchedule);
            UpdateSchedules();
        }

        
        private void tableLayoutPanel2_SizeChanged(object sender, EventArgs e)
        {
            
        }

        private void button5_Click(object sender, EventArgs e)
        {
            SaveFileDialog sfd = new() { Title = "Save image as...", Filter = "All image formats (*.png;*.jpg)|*.png;*.jpg", DefaultExt = "jpg"};
            if (sfd.ShowDialog() == DialogResult.OK)
            {
                DrawTableImage().Save(sfd.FileName);
            }
        }

        private Bitmap DrawTableImage()
        {
            //Get days included in schedules
            List<int> Days =  HelperFunctions.GetDaysIncluded(THost.SaveFile.Schedules.DaysToDisplay);

            //Default fonts and pens
            Font cellFont = new Font(FontFamily.GenericSansSerif, 12);

            //Default dimensions
            int dfHeight = 36;
            int dfWidth = 200;
            int height = dfHeight;
            int width = dfWidth;

            //Multiplying dimensions by table rows and columns
            height *= THost.SaveFile.Schedules.Items.Count + 1;
            width *= Days.Count + 1;

            //Generating blank bitmap and graphics
            var bmp = new Bitmap(width, height);
            Graphics g = Graphics.FromImage(bmp);
            g.Clear(Color.White);

            SizeF measurement = g.MeasureString("Schedules", cellFont);
            int x = GetCoordinate(0, dfWidth, measurement.Width);
            int y = GetCoordinate(0, dfHeight, measurement.Height);
            g.DrawString("Schedules",cellFont,Brushes.Black,x, y);

            //Draw backgrounds
            for (int row = 1; row < (height/dfHeight); row++)
            {
                Schedule s = THost.SaveFile.Schedules.Items[row - 1];
                string scheduleString = s.StartTime.ToString() + " - " + s.EndTime.ToString();
                measurement = g.MeasureString(scheduleString, cellFont);
                x = GetCoordinate(0, dfWidth, measurement.Width);
                y = GetCoordinate(row * dfHeight, dfHeight, measurement.Height);
                g.DrawString(scheduleString, cellFont, Brushes.Black, x, y);

                for (int col = 0; col < Days.Count; col++)
                {
                    int? sID = THost.SaveFile.Schedules.Items[row - 1].Subjects[Days[col]];
                    if (sID != null)
                    {
                        Subject sbj = THost.GetSubjectById(sID.Value);
                        int topX = dfWidth * (col + 1);
                        int topY = dfHeight * row;

                        measurement = g.MeasureString(sbj.SubjectName, cellFont);
                        
                        x = GetCoordinate(topX, dfWidth, measurement.Width);
                        y = GetCoordinate(topY, dfHeight, measurement.Height);
                        
                        g.FillRectangle(new SolidBrush(Color.FromArgb(sbj.SubjectColor)),topX,topY,dfWidth,dfHeight);
                        g.DrawString(sbj.SubjectName, cellFont, Brushes.Black, x, y);
                    }
                }
            }

            //Draw days of week
            for (int day = 0; day < Days.Count; day++)
            {
                string dayString = ((DayOfWeek)Days[day]).ToString();
                measurement = g.MeasureString(dayString, cellFont);
                x = GetCoordinate((day + 1) * dfWidth, dfWidth, measurement.Width);
                y = GetCoordinate(0, dfHeight, measurement.Height);
                g.DrawString(dayString,cellFont,Brushes.Black, x, y);
            }


            //Draw cell borders
            for (int row = 0; row < (height / dfHeight); row++)
            {
                for (int col = 0; col < (width / dfWidth); col++)
                {
                    g.DrawRectangle(Pens.Black,col * dfWidth, row * dfHeight, dfWidth, dfHeight);
                }
            }


            return bmp;
        }

        private int GetCoordinate(int startPoint, int bounds, float textSize) => startPoint + ((bounds - (int)textSize) / 2);
    }
}
