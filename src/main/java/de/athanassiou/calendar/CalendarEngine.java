package de.athanassiou.calendar;

import java.time.*;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class CalendarEngine {

    // Gauss/Spencer Gregorian Easter algorithm
    private static LocalDate easter(int year) {
        int a = year % 19;
        int b = year / 100;
        int c = year % 100;
        int d = b / 4;
        int e = b % 4;
        int f = (b + 8) / 25;
        int g = (b - f + 1) / 3;
        int h = (19 * a + b - d - g + 15) % 30;
        int i = c / 4;
        int k = c % 4;
        int l = (32 + 2 * e + 2 * i - h - k) % 7;
        int m = (a + 11 * h + 22 * l) / 451;
        int month = (h + l - 7 * m + 114) / 31;
        int day   = ((h + l - 7 * m + 114) % 31) + 1;
        return LocalDate.of(year, month, day);
    }

    // Bayern/BW holidays: national + Fronleichnam
    private static List<LocalDate> holidaysForYear(int year) {
        List<LocalDate> h = new ArrayList<>();
        LocalDate e = easter(year);

        h.add(LocalDate.of(year, 1, 1));     // Neujahr
        h.add(e.minusDays(2));               // Karfreitag
        h.add(e.plusDays(1));                // Ostermontag
        h.add(LocalDate.of(year, 5, 1));     // Tag der Arbeit
        h.add(e.plusDays(39));               // Christi Himmelfahrt
        h.add(e.plusDays(50));               // Pfingstmontag
        h.add(e.plusDays(60));               // Fronleichnam
        h.add(LocalDate.of(year, 10, 3));    // Tag der Deutschen Einheit
        h.add(LocalDate.of(year, 12, 25));   // 1. Weihnachtstag
        h.add(LocalDate.of(year, 12, 26));   // 2. Weihnachtstag
        return h;
    }

    private static int countHolidays(LocalDate start, LocalDate end) {
        int count = 0;
        for (int year = start.getYear(); year <= end.getYear(); year++) {
            for (LocalDate h : holidaysForYear(year)) {
                if (!h.isBefore(start) && h.isBefore(end)) {
                    DayOfWeek dow = h.getDayOfWeek();
                    if (dow != DayOfWeek.SATURDAY && dow != DayOfWeek.SUNDAY) {
                        count++;
                    }
                }
            }
        }
        return count;
    }

    private static long countWeekdayOccurrences(LocalDate start, LocalDate end, DayOfWeek dow) {
        long total = ChronoUnit.DAYS.between(start, end);
        LocalDate first = start;
        while (first.getDayOfWeek() != dow) first = first.plusDays(1);
        if (first.isBefore(end)) {
            return (ChronoUnit.DAYS.between(first, end) / 7) + 1;
        }
        return 0;
    }

    public static CalcResult calculate(UserPreferences prefs) {
        LocalDate today = LocalDate.now();

        int tMonth = prefs.getTargetMonth();
        int tYear  = prefs.getTargetYear();
        int lastDay = YearMonth.of(tYear, tMonth).lengthOfMonth();
        LocalDate target = LocalDate.of(tYear, tMonth, lastDay);

        CalcResult r = new CalcResult();
        r.targetDate  = target;

        r.daysBetween  = ChronoUnit.DAYS.between(today, target);

        Period period  = Period.between(today, target);
        r.periodYears  = period.getYears();
        r.periodMonths = period.getMonths();
        r.periodDays   = period.getDays();

        long saturdays = countWeekdayOccurrences(today, target, DayOfWeek.SATURDAY);
        long sundays   = countWeekdayOccurrences(today, target, DayOfWeek.SUNDAY);
        r.weekendDays  = saturdays + sundays;
        r.businessDays = r.daysBetween - r.weekendDays;

        r.holidays = countHolidays(today, target);

        // Replicate myDataPack.Calculate() vacation/training logic:
        // years = (targetYear - currentYear) - 1
        // x = targetMonth / 12 * annualVacation
        int years  = (tYear - today.getYear()) - 1;
        if (years < 0) years = 0;
        float monthFraction = (float) tMonth / 12;

        r.vacation = (long)(prefs.getRemainVacation()
                + years * prefs.getAnnualVacation()
                + (int)(monthFraction * prefs.getAnnualVacation()));

        r.training = (long)(prefs.getCurrentTraining()
                + years * prefs.getAnnualTraining()
                + (int)(monthFraction * prefs.getAnnualTraining()));

        r.workdays = r.businessDays - (r.holidays + r.vacation + r.training);

        r.age = tYear - prefs.getBirthYear();

        return r;
    }
}
