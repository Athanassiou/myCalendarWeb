package de.athanassiou.calendar;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class UserPreferences {

    // Defaults: month=12, year=2029, remainVacation=20,
    // annualVacation=30, currentTraining=2, annualTraining=4, birthMonth=12, birthYear=1964
    private int targetMonth    = 12;
    private int targetYear     = 2029;
    private int remainVacation = 20;
    private int annualVacation = 30;
    private int currentTraining= 2;
    private int annualTraining = 4;
    private int birthMonth     = 12;
    private int birthYear      = 1964;

    private static final String COOKIE_NAME = "d2g_prefs";

    public static UserPreferences fromCookies(HttpServletRequest req) {
        UserPreferences p = new UserPreferences();
        if (req.getCookies() == null) return p;
        for (Cookie c : req.getCookies()) {
            if (COOKIE_NAME.equals(c.getName())) {
                p.parse(c.getValue());
                break;
            }
        }
        return p;
    }

    public void saveToCookies(HttpServletResponse resp) {
        String value = targetMonth + "_" + targetYear + "_" + remainVacation + "_"
                + annualVacation + "_" + currentTraining + "_" + annualTraining + "_"
                + birthMonth + "_" + birthYear;
        Cookie c = new Cookie(COOKIE_NAME, value);
        c.setMaxAge(365 * 24 * 3600);
        c.setPath("/");
        resp.addCookie(c);
    }

    private void parse(String value) {
        try {
            String[] parts = value.split("_");
            if (parts.length >= 8) {
                targetMonth     = Integer.parseInt(parts[0]);
                targetYear      = Integer.parseInt(parts[1]);
                remainVacation  = Integer.parseInt(parts[2]);
                annualVacation  = Integer.parseInt(parts[3]);
                currentTraining = Integer.parseInt(parts[4]);
                annualTraining  = Integer.parseInt(parts[5]);
                birthMonth      = Integer.parseInt(parts[6]);
                birthYear       = Integer.parseInt(parts[7]);
            }
        } catch (NumberFormatException ignored) { }
    }

    public int getTargetMonth()     { return targetMonth; }
    public int getTargetYear()      { return targetYear; }
    public int getRemainVacation()  { return remainVacation; }
    public int getAnnualVacation()  { return annualVacation; }
    public int getCurrentTraining() { return currentTraining; }
    public int getAnnualTraining()  { return annualTraining; }
    public int getBirthMonth()      { return birthMonth; }
    public int getBirthYear()       { return birthYear; }

    public void setTargetMonth(int v)     { this.targetMonth = clamp(v, 1, 12); }
    public void setTargetYear(int v)      { this.targetYear = clamp(v, 2026, 2060); }
    public void setRemainVacation(int v)  { this.remainVacation = clamp(v, 0, 99); }
    public void setAnnualVacation(int v)  { this.annualVacation = clamp(v, 0, 99); }
    public void setCurrentTraining(int v) { this.currentTraining = clamp(v, 0, 99); }
    public void setAnnualTraining(int v)  { this.annualTraining = clamp(v, 0, 99); }
    public void setBirthMonth(int v)      { this.birthMonth = clamp(v, 1, 12); }
    public void setBirthYear(int v)       { this.birthYear = clamp(v, 1940, 2010); }

    private int clamp(int v, int min, int max) {
        return Math.max(min, Math.min(max, v));
    }
}
