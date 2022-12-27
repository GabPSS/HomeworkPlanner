using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace HomeworkPlanner
{
    public partial class TestForm : Form
    {
        SaveFile file;

        public TestForm()
        {
            InitializeComponent();
            file = new SaveFile();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Task task = new Task();
            propertyGrid1.SelectedObject = task;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            textBox1.Text = file.MakeJSON();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            file = SaveFile.FromJSON(textBox1.Text);
        }

        private void button5_Click(object sender, EventArgs e)
        {
            file.Tasks.Add(propertyGrid1.SelectedObject as Task);
            propertyGrid1.SelectedObject = null;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            file.Subjects.Add(textBox2.Text);
            listBox1.Items.Add(textBox2.Text);
        }
    }
}
