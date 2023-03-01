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
    public partial class ScheduleMgmtForm : Form
    {
        public Schedule Schedule { get; set; } = new Schedule();
        public TimeSpan NewStartTime { get
            {
                return dateTimePicker1.Value.TimeOfDay;
            } }
        public TimeSpan NewEndTime
        {
            get
            {
                return dateTimePicker2.Value.TimeOfDay;
            }
        }
        public ScheduleMgmtForm()
        {
            InitializeComponent();
        }

        private void ScheduleMgmtForm_Load(object sender, EventArgs e)
        {
            dateTimePicker1.Value = new DateTime(DateTime.Today.Year, DateTime.Today.Month, DateTime.Today.Day, Schedule.StartTime.Hours, Schedule.StartTime.Minutes, Schedule.StartTime.Seconds);
            dateTimePicker2.Value = new DateTime(DateTime.Today.Year, DateTime.Today.Month, DateTime.Today.Day, Schedule.EndTime.Hours, Schedule.EndTime.Minutes, Schedule.EndTime.Seconds);
        }
    }
}
