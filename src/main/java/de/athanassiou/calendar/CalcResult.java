package de.athanassiou.calendar;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class CalcResult {

    public LocalDate targetDate;
    public long daysBetween;
    public int  periodYears;    // way2go[2]
    public int  periodMonths;   // way2go[1]
    public int  periodDays;     // way2go[0]
    public long weekendDays;
    public long businessDays;
    public int  holidays;
    public long vacation;
    public long training;
    public long workdays;
    public int  age;

    private static final DateTimeFormatter FMT =
            DateTimeFormatter.ofPattern("d. MMM yyyy", Locale.GERMAN);

    public String getFormattedDate() {
        return targetDate != null ? targetDate.format(FMT) : "";
    }
}
