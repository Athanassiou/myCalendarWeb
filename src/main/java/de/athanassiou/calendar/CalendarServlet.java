package de.athanassiou.calendar;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(urlPatterns = {"", "/index"})
public class CalendarServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        UserPreferences prefs = UserPreferences.fromCookies(req);
        CalcResult result = CalendarEngine.calculate(prefs);

        req.setAttribute("result", result);
        req.setAttribute("prefs",  prefs);

        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        UserPreferences prefs = UserPreferences.fromCookies(req);

        parseIntParam(req, "targetMonth",     prefs::setTargetMonth);
        parseIntParam(req, "targetYear",      prefs::setTargetYear);
        parseIntParam(req, "remainVacation",  prefs::setRemainVacation);
        parseIntParam(req, "annualVacation",  prefs::setAnnualVacation);
        parseIntParam(req, "currentTraining", prefs::setCurrentTraining);
        parseIntParam(req, "annualTraining",  prefs::setAnnualTraining);
        parseIntParam(req, "birthMonth",      prefs::setBirthMonth);
        parseIntParam(req, "birthYear",       prefs::setBirthYear);

        prefs.saveToCookies(resp);
        resp.sendRedirect(req.getContextPath() + "/");
    }

    @FunctionalInterface
    private interface IntSetter { void set(int v); }

    private void parseIntParam(HttpServletRequest req, String name, IntSetter setter) {
        String val = req.getParameter(name);
        if (val != null && !val.isBlank()) {
            try { setter.set(Integer.parseInt(val.trim())); }
            catch (NumberFormatException ignored) { }
        }
    }
}
