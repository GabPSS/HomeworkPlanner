using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace HomeworkPlanner.Properties
{
    public partial class DayCancelForm : Form
    {
        public string Message { get { return textBox1.Text; } }
        public bool IsCancelled { get { return checkBox1.Checked; } }
        public DateTime Date { get { return dateTimePicker1.Value; } }

        public DayCancelForm()
        {
            InitializeComponent();
        }
    }
}
