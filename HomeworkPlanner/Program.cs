namespace HomeworkPlanner
{
    internal static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        private static void Main(string[] args)
        {
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            ApplicationConfiguration.Initialize();
            MainForm mf = args.Length > 0 && File.Exists(args[0]) ? new MainForm(args[0]) : new MainForm();
            Application.Run(mf);
        }
    }
}