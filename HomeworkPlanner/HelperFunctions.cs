using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HomeworkPlanner
{
    internal static class HelperFunctions
    {
        #region Date Calculation
        public static DateTime GetSunday(DateTime dateTime)
        {
            DayOfWeek dayOfWeek = dateTime.DayOfWeek;

            return dateTime.AddDays(0 - (double)dayOfWeek);
        }

        public static int GetDayCount(DaysToInclude data)
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

        public static List<int> GetDaysIncluded(DaysToInclude data)
        {
            List<int> output = new();
            int numData = (int)data;
            int i2 = 6;
            for (int i = 64; i >= 1; i /= 2)
            {
                if (numData - i >= 0)
                {
                    output.Add(i2);
                    numData -= i;
                }
                i2--;
            }
            output.Reverse();
            return output;
        }
        #endregion
    }
}
