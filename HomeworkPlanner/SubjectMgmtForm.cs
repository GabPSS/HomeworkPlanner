using HomeworkPlanner.TaskControls;

namespace HomeworkPlanner
{
    public partial class SubjectMgmtForm : Form
    {
        #region Properties
        public TaskHost TaskHost { get; set; }
        public SubjectList SubjectList { get { return TaskHost.SaveFile.Subjects; } }
        #endregion
        #region Form init functions
        public SubjectMgmtForm(TaskHost taskHost)
        {
            InitializeComponent();
            TaskHost = taskHost;
            UpdateSubjects();
        }
        public void UpdateSubjects()
        {
            listView1.Items.Clear();
            if (checkBox1.Checked)
            {
                TaskHost.SortSubjectsByName();
            }
            for (int i = 0; i < SubjectList.Items.Count; i++)
            {
                SubjectControl ctrl = new(SubjectList.Items[i]);
                listView1.Items.Add(ctrl);
            }
        }
        #endregion
        #region Subject management buttons
        private void addSubject(object sender, EventArgs e)
        {
            SubjectList.Add(textBox1.Text);
            UpdateSubjects();
            textBox1.Clear();
            textBox1.Focus();
        }
        private void editSubjectButtonClick(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count > 0)
            {
                listView1.SelectedItems[0].BeginEdit();
            }
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
        #endregion
        #region ListView functions
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
        private void listView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            button3.Enabled = listView1.SelectedIndices.Count > 0;
            button4.Enabled = listView1.SelectedIndices.Count > 0;

            button5.BackColor = listView1.SelectedIndices.Count > 0 ? Color.FromArgb(SubjectList.Items[listView1.SelectedIndices[0]].SubjectColor) : SystemColors.Control;
        }
        #endregion

        private void SubjectMgmtForm_Load(object sender, EventArgs e)
        {
            groupBox1.Focus();
            textBox1.Focus();
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            UpdateSubjects();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            if (listView1.SelectedIndices.Count > 0)
            {
                ColorDialog cd = new() { Color = button5.BackColor };
                if (cd.ShowDialog() == DialogResult.OK)
                {
                    SubjectList.Items[listView1.SelectedIndices[0]].SubjectColor = cd.Color.ToArgb();
                    button5.BackColor = cd.Color;
                }
            }
        }
    }
}
