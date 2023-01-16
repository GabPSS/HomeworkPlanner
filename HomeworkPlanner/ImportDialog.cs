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
    public partial class ImportDialog : Form
    {
        private SaveFile? importSaveFile;
        private TaskHost TargetTaskHost;

        public ImportDialog(TaskHost taskHost)
        {
            InitializeComponent();
            TargetTaskHost = taskHost;

            comboBox1.Items.Add(Subject.DefaultMissingSubjectText);
            comboBox1.Items.AddRange(taskHost.SaveFile.Subjects.Items.ToArray());
            comboBox1.SelectedIndex = 0;
        }

        private void button3_Click(object sender, EventArgs e)
        {
            if (SaveFileOpenDialog.ShowDialog() == DialogResult.OK && tabControl1.SelectedTab == SaveFileTabPage)
            {
                importSaveFile = SaveFile.FromJSON(File.ReadAllText(SaveFileOpenDialog.FileName));
                UpdateSaveFileImportControls(SaveFileOpenDialog.FileName);
            }
        }

        private void UpdateSaveFileImportControls(string path)
        {
            if (importSaveFile != null)
            {
                checkedListBox1.Items.Clear();
                checkedListBox2.Items.Clear();
                textBox1.Text = path;

                for (int i = 0; i < importSaveFile.Tasks.Items.Count; i++)
                {
                    checkedListBox1.Items.Add(importSaveFile.Tasks.Items[i],true);
                }

                for (int i = 0; i < importSaveFile.Subjects.Items.Count; i++)
                {
                    checkedListBox2.Items.Add(importSaveFile.Subjects.Items[i],true);
                }

            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (tabControl1.SelectedTab == SaveFileTabPage && importSaveFile != null)
            {
                //Create an association between subjects
                List<(int oldID, int newID)> SubjectAssociations = new();

                //Add subjects
                for (int i = 0; i < checkedListBox2.CheckedItems.Count; i++)
                {
                    if (checkedListBox2.CheckedItems[i] is Subject s)
                    {
                        int newID = TargetTaskHost.SaveFile.Subjects.Add(s.SubjectName);
                        SubjectAssociations.Add((s.SubjectID, newID));
                    }
                }

                for (int i = 0; i < checkedListBox1.CheckedItems.Count; i++)
                {
                    if (checkedListBox1.CheckedItems[i] is Task task)
                    {
                        int sID = -1;
                        for (int x = 0; x < SubjectAssociations.Count; x++)
                        {
                            if (SubjectAssociations[x].oldID == task.SubjectID)
                            {
                                sID = SubjectAssociations[x].newID;
                            }
                        }
                        task.SubjectID = sID;
                        TargetTaskHost.SaveFile.Tasks.Add(task);
                    }
                }
            }
            else if (tabControl1.SelectedTab == NameListTabPage)
            {
                for (int i = 0; i < textBox2.Lines.Length; i++)
                {
                    string text = textBox2.Lines[i];
                    int subjectID = -1;
                    if (comboBox1.SelectedItem is Subject s)
                    {
                        subjectID = s.SubjectID;
                    }
                    Task task = new Task() { DueDate = dateTimePicker1.Value, Name = text, SubjectID = subjectID, IsCompleted = checkBox1.Checked };
                    TargetTaskHost.SaveFile.Tasks.Add(task);
                }
            }
        }

        private void button4_Click(object sender, EventArgs e)
        {
            for (int i = 0; i < checkedListBox1.Items.Count; i++)
            {
                checkedListBox1.SetItemChecked(i, true);
            }
        }

        private void button5_Click(object sender, EventArgs e)
        {
            for (int i = 0; i < checkedListBox1.Items.Count; i++)
            {
                checkedListBox1.SetItemChecked(i, false);
            }
        }

        private void button6_Click(object sender, EventArgs e)
        {
            for (int i = 0; i < checkedListBox2.Items.Count; i++)
            {
                checkedListBox2.SetItemChecked(i, true);
            }
        }

        private void button7_Click(object sender, EventArgs e)
        {
            for (int i = 0; i < checkedListBox2.Items.Count; i++)
            {
                checkedListBox2.SetItemChecked(i, false);
            }
        }
    }
}
