package de.athanassiou.calendar;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/slider")
public class SliderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        UserPreferences prefs = UserPreferences.fromCookies(req);

        String ageParam = req.getParameter("age");
        if (ageParam != null) {
            try {
                int age = Integer.parseInt(ageParam.trim());
                prefs.setTargetYear(prefs.getBirthYear() + age);
                prefs.setTargetMonth(prefs.getBirthMonth());
            } catch (NumberFormatException ignored) { }
        }

        CalcResult r = CalendarEngine.calculate(prefs);

        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");
        resp.getWriter().write(
            "{\"targetDate\":\"" + r.getFormattedDate() + "\""
            + ",\"daysBetween\":" + r.daysBetween
            + ",\"businessDays\":" + r.businessDays
            + ",\"holidays\":" + r.holidays
            + ",\"vacation\":" + r.vacation
            + ",\"training\":" + r.training
            + ",\"workdays\":" + r.workdays
            + ",\"weekendDays\":" + r.weekendDays
            + ",\"periodYears\":" + r.periodYears
            + ",\"periodMonths\":" + r.periodMonths
            + ",\"periodDays\":" + r.periodDays
            + ",\"age\":" + r.age
            + "}"
        );
    }
}
