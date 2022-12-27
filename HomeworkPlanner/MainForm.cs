namespace HomeworkPlanner
{
    public partial class MainForm : Form
    {
        public enum DaysToInclude { Sunday = 1, Monday = 2, Tuesday = 4, Wednesday = 8, Thursday = 16, Friday = 32, Saturday = 64 }
        public int FutureWeeks = 2;
        public DaysToInclude DaysToDisplay { get; set; } = DaysToInclude.Monday | DaysToInclude.Tuesday | DaysToInclude.Wednesday | DaysToInclude.Thursday | DaysToInclude.Friday;

        public MainForm()
        {
            InitializeComponent();
            SetUpPlanningPanel();
        }

        private void SetUpPlanningPanel()
        {
            //Set up columns and rows
            int colCount = GetDayCount(DaysToDisplay);
            int rowCount = FutureWeeks + 1;

            PlanningPanel.ColumnCount = colCount;
            for (int i = 0; i < colCount; i++)
            {
                PlanningPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            }
            PlanningPanel.RowCount = rowCount;
            for (int i = 0; i < colCount; i++)
            {
                PlanningPanel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            }

        }

        private static DateTime GetSunday(DateTime dateTime)
        {
            DayOfWeek dayOfWeek = dateTime.DayOfWeek;

            return dateTime.AddDays(0 - (double)dayOfWeek);
        }

        private static int GetDayCount(DaysToInclude data)
        {
            int numericData = (int)data;
            int dayCount = 0;
            for (int i = 64; i >= 1; i /= 2)
            {
                if (numericData - i >= 0)
                {
                    dayCount++;
                    numericData -= i;
                }
            }
            return dayCount;
        }
    }
}