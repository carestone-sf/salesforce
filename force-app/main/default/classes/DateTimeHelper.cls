public with sharing class DateTimeHelper {
    public DateTimeHelper() {
        
    }

    // Method to get the a certain DateTime 
    // When the date is after friday 12am and before monday 12am, it will add 72 Hours, 
    // so that the time will be during the week
    public static DateTime getDateTime()
    {
        return getDateTime(0, 'hours');
    }

    // The Integer addTime is used to determine how many hours should be added to the current Time
    public static DateTime getDateTime(Integer addTime)
    {
        return getDateTime(addTime, 'hours');
    }

    // Here it's also possible to add Days and Hours, depending on the type
    public static DateTime getDateTime(Integer addTime, String type)
    {
        DateTime current = DateTime.now();
        if(type == 'days')
        {
            current = current.addDays(addTime);
        }
        else if(type == 'hours')
        {
            current = current.addHours(addTime);
        }
        String dayOfWeek = current.format('E');
        if(dayOfWeek == 'Sat' || dayOfWeek == 'Sun' || (dayOfWeek == 'Fri' && current.hour() > 12) || (dayOfWeek == 'Mon' && current.hour() < 12))
        {
            current = current.addHours(72);
        }
        return current;
    }
    
    // Checks if a DateTime is on the weekend and if yes adds 72 hours
    public static DateTime checkAndSetDateTimeIfWeekend(DateTime dt)
    {
        String dayOfWeek = dt.format('E');
        if(dayOfWeek == 'Sat' || dayOfWeek == 'Sun' || (dayOfWeek == 'Fri' && dt.hour() > 12) || (dayOfWeek == 'Mon' && dt.hour() < 12))
        {
            dt = dt.addHours(72);
        }
        return dt;
    }
    
}