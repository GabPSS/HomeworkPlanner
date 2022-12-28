﻿using System;
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
    public partial class SubjectMgmtForm : Form
    {
        public TaskHost TaskHost { get; set; }
        public SubjectList SubjectList { get { return TaskHost.SaveFile.Subjects; } }
        public SubjectMgmtForm(TaskHost taskHost)
        {
            InitializeComponent();
            TaskHost = taskHost;
            UpdateSubjects();
        }

        public void UpdateSubjects()
        {
            listView1.Items.Clear();
            for (int i = 0; i < SubjectList.Items.Count; i++)
            {
                SubjectControl ctrl = new(SubjectList.Items[i]);
                listView1.Items.Add(ctrl);
            }
        }

        private void addSubject(object sender, EventArgs e)
        {
            SubjectList.Add(textBox1.Text);
            UpdateSubjects();
        }

        private void listView1_AfterLabelEdit(object sender, LabelEditEventArgs e)
        {
            if (e.Label != null)
            {
                SubjectList.Items[e.Item].SubjectName = e.Label;
            }
            else
            {
                e.CancelEdit = true;
            }
        }

        private void editSubjectButtonClick(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count > 0)
            {
                listView1.SelectedItems[0].BeginEdit();
            }
        }

        private void listView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            button3.Enabled = listView1.SelectedIndices.Count > 0;
            button4.Enabled = listView1.SelectedIndices.Count > 0;
        }

        private void deleteButtonClick(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count > 1)
            {
                if (MessageBox.Show("Are you sure you want to delete " + listView1.SelectedItems.Count + " subject(s)?", "Delete subject(s)", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.No)
                    return;
            }

            for (int i = 0; i < listView1.SelectedItems.Count; i++)
            {
                Subject deletingSubject = ((SubjectControl)listView1.SelectedItems[i]).SelectedSubject;
                TaskHost.SaveFile.Subjects.Items.Remove(deletingSubject);
            }
            UpdateSubjects();
        }
    }
}
