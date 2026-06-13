<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="de.athanassiou.calendar.CalcResult, de.athanassiou.calendar.UserPreferences" %>
<%
    CalcResult      result = (CalcResult)      request.getAttribute("result");
    UserPreferences prefs  = (UserPreferences) request.getAttribute("prefs");
    int minAge             = 61;
    int maxAge             = 70;
    int ageRange           = maxAge - minAge;
    int tickAge1           = minAge;
    int tickAge2           = minAge + ageRange / 3;
    int tickAge3           = minAge + 2 * ageRange / 3;
    int tickAge4           = maxAge;
    String ctx             = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Days 2 Go</title>
    <link rel="stylesheet" href="/styles/css/all.css">
    <link rel="stylesheet" href="/styles/n3.css">
    <link rel="stylesheet" href="/styles/n3-driver.css">
    <style>
        body.compact .main { margin-left: var(--sidebar-compact); }
        .main {
            margin-left: var(--sidebar-width);
            padding: 1.5rem;
            min-height: 100vh;
            overflow-y: auto;
        }
        .dashboard {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1rem;
            margin-bottom: 2rem;
        }
        @media (max-width: 1100px) { .dashboard { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 600px)  { .dashboard { grid-template-columns: 1fr; } }

        .panel {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 1.5rem 1rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.4rem;
            min-height: 260px;
            justify-content: center;
        }
        .panel-title {
            font-size: 0.78rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.08em;
            margin-bottom: 0.5rem;
        }
        .big-num {
            font-size: 3rem;
            font-weight: 700;
            color: var(--accent);
            line-height: 1;
        }
        .med-num {
            font-size: 2rem;
            font-weight: 700;
            color: var(--accent);
            line-height: 1;
        }
        .lbl {
            font-size: 0.75rem;
            color: var(--text-muted);
        }
        .sep {
            width: 80%;
            border: none;
            border-top: 1px solid var(--border);
            margin: 0.6rem 0;
        }
        .countdown-row {
            display: flex;
            gap: 1.5rem;
            justify-content: center;
            align-items: flex-end;
        }
        .countdown-cell { text-align: center; }

        /* Detail grid */
        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.3rem 1rem;
            width: 100%;
        }
        .detail-cell { text-align: center; padding: 0.3rem 0; }
        .detail-sep {
            grid-column: 1 / -1;
            border: none;
            border-top: 1px solid var(--border);
            margin: 0.2rem 0;
        }

        /* Slider */
        input[type="range"] {
            width: 90%;
            accent-color: var(--accent);
            margin-top: 0.5rem;
        }
        .slider-ticks {
            display: flex;
            justify-content: space-between;
            width: 90%;
            font-size: 0.65rem;
            color: var(--text-muted);
        }

        /* Settings form */
        .settings-card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 1.5rem;
        }
        .settings-title {
            font-size: 0.78rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.08em;
            margin-bottom: 1rem;
        }
        .settings-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 0.8rem 1.5rem;
        }
        .field label {
            display: block;
            font-size: 0.75rem;
            color: var(--text-muted);
            margin-bottom: 0.25rem;
        }
        .field input[type="number"], .field select {
            width: 100%;
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            color: var(--text);
            padding: 0.4rem 0.6rem;
            font-size: 0.9rem;
        }
        .field input[type="number"]:focus, .field select:focus {
            outline: none;
            border-color: var(--accent);
        }
        .btn-save {
            margin-top: 1rem;
            background: var(--accent);
            color: #111;
            border: none;
            border-radius: var(--radius);
            padding: 0.5rem 1.6rem;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-save:hover { opacity: 0.85; }

        /* Settings modal */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.55);
            z-index: 400;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal-overlay .settings-card {
            position: relative;
            width: 90%;
            max-width: 640px;
            max-height: 85vh;
            overflow-y: auto;
        }
        .modal-close {
            position: absolute;
            top: 0.9rem;
            right: 0.9rem;
            background: none;
            border: none;
            color: var(--text-muted);
            font-size: 1.3rem;
            line-height: 1;
            cursor: pointer;
        }
        .modal-close:hover { color: var(--text); }

        /* Panel visibility */
        body.hide-clock    #panel-clock,
        body.hide-overview #panel-overview,
        body.hide-details  #panel-details,
        body.hide-age      #panel-age { display: none; }

        /* Toggle switches */
        .switch-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0.7rem 0;
            border-bottom: 1px solid var(--border);
        }
        .switch-row:last-child { border-bottom: none; }
        .switch-row span { font-size: 0.9rem; color: var(--text); }
        .switch {
            position: relative;
            display: inline-block;
            width: 42px;
            height: 24px;
            flex-shrink: 0;
        }
        .switch input { opacity: 0; width: 0; height: 0; }
        .switch .switch-track {
            position: absolute;
            inset: 0;
            background: var(--border);
            border-radius: 24px;
            cursor: pointer;
            transition: background 0.2s;
        }
        .switch .switch-track::before {
            content: "";
            position: absolute;
            left: 3px;
            bottom: 3px;
            width: 18px;
            height: 18px;
            background: var(--text-muted);
            border-radius: 50%;
            transition: transform 0.2s, background 0.2s;
        }
        .switch input:checked + .switch-track { background: var(--accent-dim); }
        .switch input:checked + .switch-track::before {
            transform: translateX(18px);
            background: var(--accent);
        }
    </style>
</head>
<body>

<script>
(function () {
    var cls = [];
    if (localStorage.getItem('n3theme') === 'grey') cls.push('grey-mode');
    if (localStorage.getItem('n3sidebar') === 'compact') cls.push('compact');
    try {
        var panels = JSON.parse(localStorage.getItem('d2g_panels') || '{}');
        if (panels.clock    === false) cls.push('hide-clock');
        if (panels.overview === false) cls.push('hide-overview');
        if (panels.details  === false) cls.push('hide-details');
        if (panels.age      === false) cls.push('hide-age');
    } catch (e) {}
    if (cls.length) document.body.className = cls.join(' ');
})();
</script>

<div class="sidebar-overlay" id="sidebar-overlay"></div>
<button class="hamburger" id="hamburger"><i class="fa fa-solid fa-bars"></i></button>

<aside class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <a class="sidebar-logo" href="<%= ctx %>/">
            <div class="sidebar-logo-icon">D2</div>
            <span class="sidebar-logo-text">Days 2 Go</span>
        </a>
    </div>
    <nav class="sidebar-nav">
        <span class="nav-section-label">Rentenrechner</span>
        <a class="nav-item active" href="<%= ctx %>/"><i class="fa-solid fa-fw fa-calendar-days"></i> Dashboard</a>
        <a class="nav-item" href="#" id="settingsLink"><i class="fa-solid fa-fw fa-sliders"></i> Einstellungen</a>
        <a class="nav-item" href="#" id="panelsLink"><i class="fa-solid fa-fw fa-table-cells"></i> Panels</a>
    </nav>
    <div class="sidebar-footer">
        <button class="theme-toggle" id="themeToggle">
            <i class="fa fa-circle-half-stroke"></i>
            <span id="themeLabel">Grey Mode</span>
        </button>
        <button class="theme-toggle" id="compactToggle" title="Sidebar kompaktieren">
            <i class="fa-solid fa-angles-left" id="compactIcon"></i>
            <span id="compactLabel">Kompakt</span>
        </button>
    </div>
</aside>

<main class="main">

    <div class="dashboard">

        <!-- Panel 1: Digitaluhr -->
        <div class="panel" id="panel-clock">
            <div class="panel-title">Uhrzeit &amp; Datum</div>
            <div class="big-num" id="clock-day" style="font-size:1.4rem; margin-bottom:0.2rem"></div>
            <div class="lbl"    id="clock-date" style="font-size:1.1rem; color:var(--text)"></div>
            <hr class="sep">
            <div class="big-num" id="clock-time" style="font-size:2.8rem; font-variant-numeric:tabular-nums"></div>
        </div>

        <!-- Panel 2: Übersicht -->
        <div class="panel" id="panel-overview">
            <div class="panel-title">Übersicht</div>
            <div class="lbl">Zieldatum</div>
            <div id="ov-date" style="font-size:1.1rem; font-weight:600; color:var(--text)"><%= result.getFormattedDate() %></div>
            <hr class="sep">
            <div class="countdown-row">
                <div class="countdown-cell">
                    <div class="med-num" id="ov-years"><%= result.periodYears %></div>
                    <div class="lbl"><%= result.periodYears == 1 ? "Jahr" : "Jahre" %></div>
                </div>
                <div class="countdown-cell">
                    <div class="med-num" id="ov-months"><%= result.periodMonths %></div>
                    <div class="lbl"><%= result.periodMonths == 1 ? "Monat" : "Monate" %></div>
                </div>
                <div class="countdown-cell">
                    <div class="med-num" id="ov-days"><%= result.periodDays %></div>
                    <div class="lbl"><%= result.periodDays == 1 ? "Tag" : "Tage" %></div>
                </div>
            </div>
            <hr class="sep">
            <div class="lbl">Arbeitstage</div>
            <div class="big-num" id="ov-work"><%= result.workdays %></div>
        </div>

        <!-- Panel 3: Detailwerte -->
        <div class="panel" id="panel-details">
            <div class="panel-title">Detailwerte</div>
            <div class="detail-grid">
                <div class="detail-cell">
                    <div class="lbl">Tage</div>
                    <div class="med-num" id="dv-total"><%= result.daysBetween %></div>
                </div>
                <div class="detail-cell">
                    <div class="lbl">Werktage</div>
                    <div class="med-num" id="dv-biz"><%= result.businessDays %></div>
                </div>
                <hr class="detail-sep">
                <div class="detail-cell">
                    <div class="lbl">Wochenende</div>
                    <div class="med-num" id="dv-we"><%= result.weekendDays %></div>
                </div>
                <div class="detail-cell">
                    <div class="lbl">Feiertage</div>
                    <div class="med-num" id="dv-hol"><%= result.holidays %></div>
                </div>
                <hr class="detail-sep">
                <div class="detail-cell">
                    <div class="lbl">Urlaub</div>
                    <div class="med-num" id="dv-vac"><%= result.vacation %></div>
                </div>
                <div class="detail-cell">
                    <div class="lbl">Fortbildung</div>
                    <div class="med-num" id="dv-train"><%= result.training %></div>
                </div>
            </div>
        </div>

        <!-- Panel 4: Zielalter -->
        <div class="panel" id="panel-age">
            <div class="panel-title">Zielalter</div>
            <div class="lbl">Alter bei Zieldatum</div>
            <div class="big-num" id="sl-age"><%= result.age %></div>
            <input type="range" id="alter-slider"
                   min="<%= minAge %>" max="<%= maxAge %>"
                   value="<%= result.age %>">
            <div class="slider-ticks">
                <span><%= tickAge1 %></span>
                <span><%= tickAge2 %></span>
                <span><%= tickAge3 %></span>
                <span><%= tickAge4 %></span>
            </div>
            <hr class="sep">
            <div class="lbl" style="font-size:0.7rem">Arbeitstage bei diesem Alter</div>
            <div class="med-num" id="sl-work"><%= result.workdays %></div>
        </div>

    </div><!-- /dashboard -->

    <!-- Settings form (modal) -->
    <div class="modal-overlay" id="settingsOverlay">
    <div class="settings-card" id="settings">
        <button type="button" class="modal-close" id="settingsClose" aria-label="Schließen"><i class="fa-solid fa-xmark"></i></button>
        <div class="settings-title"><i class="fa-solid fa-sliders"></i> Einstellungen</div>
        <form method="post" action="<%= ctx %>/">
            <div class="settings-grid">
                <div class="field">
                    <label>Ziel-Monat</label>
                    <select name="targetMonth">
                        <% String[] mnames = {"Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"};
                           for (int i=1; i<=12; i++) { %>
                        <option value="<%= i %>"<%= prefs.getTargetMonth()==i?" selected":"" %>><%= mnames[i-1] %></option>
                        <% } %>
                    </select>
                </div>
                <div class="field">
                    <label>Ziel-Jahr</label>
                    <input type="number" name="targetYear" value="<%= prefs.getTargetYear() %>" min="2026" max="2060">
                </div>
                <div class="field">
                    <label>Resturlaub (laufendes Jahr)</label>
                    <input type="number" name="remainVacation" value="<%= prefs.getRemainVacation() %>" min="0" max="99">
                </div>
                <div class="field">
                    <label>Urlaub p.a. (Tage)</label>
                    <input type="number" name="annualVacation" value="<%= prefs.getAnnualVacation() %>" min="0" max="99">
                </div>
                <div class="field">
                    <label>Fortbildung (laufendes Jahr)</label>
                    <input type="number" name="currentTraining" value="<%= prefs.getCurrentTraining() %>" min="0" max="99">
                </div>
                <div class="field">
                    <label>Fortbildung p.a. (Tage)</label>
                    <input type="number" name="annualTraining" value="<%= prefs.getAnnualTraining() %>" min="0" max="99">
                </div>
                <div class="field">
                    <label>Geburtsmonat</label>
                    <select name="birthMonth">
                        <% for (int i=1; i<=12; i++) { %>
                        <option value="<%= i %>"<%= prefs.getBirthMonth()==i?" selected":"" %>><%= mnames[i-1] %></option>
                        <% } %>
                    </select>
                </div>
                <div class="field">
                    <label>Geburtsjahr</label>
                    <input type="number" name="birthYear" value="<%= prefs.getBirthYear() %>" min="1940" max="2010">
                </div>
            </div>
            <button type="submit" class="btn-save">Übernehmen</button>
        </form>
    </div>
    </div>

    <!-- Panels modal -->
    <div class="modal-overlay" id="panelsOverlay">
    <div class="settings-card" id="panels">
        <button type="button" class="modal-close" id="panelsClose" aria-label="Schließen"><i class="fa-solid fa-xmark"></i></button>
        <div class="settings-title"><i class="fa-solid fa-table-cells"></i> Panels</div>
        <div class="switch-row">
            <span>Uhrzeit &amp; Datum</span>
            <label class="switch">
                <input type="checkbox" id="panel-toggle-clock">
                <span class="switch-track"></span>
            </label>
        </div>
        <div class="switch-row">
            <span>Übersicht</span>
            <label class="switch">
                <input type="checkbox" id="panel-toggle-overview">
                <span class="switch-track"></span>
            </label>
        </div>
        <div class="switch-row">
            <span>Detailwerte</span>
            <label class="switch">
                <input type="checkbox" id="panel-toggle-details">
                <span class="switch-track"></span>
            </label>
        </div>
        <div class="switch-row">
            <span>Zielalter</span>
            <label class="switch">
                <input type="checkbox" id="panel-toggle-age">
                <span class="switch-track"></span>
            </label>
        </div>
    </div>
    </div>

</main>

<script src="<%= ctx %>/n3Sidebar.js"></script>
<script>
(function () {
    // ---- Digital clock ----
    var days = ['Sonntag','Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag'];
    var months = ['Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember'];
    function pad(n) { return n < 10 ? '0' + n : n; }
    function tick() {
        var d = new Date();
        document.getElementById('clock-day').textContent  = days[d.getDay()];
        document.getElementById('clock-date').textContent = d.getDate() + '. ' + months[d.getMonth()] + ' ' + d.getFullYear();
        document.getElementById('clock-time').textContent = pad(d.getHours()) + ':' + pad(d.getMinutes()) + ':' + pad(d.getSeconds());
    }
    tick();
    setInterval(tick, 1000);

    // ---- Zielalter Slider ----
    var slider  = document.getElementById('alter-slider');
    var birthYear = <%= prefs.getBirthYear() %>;

    function updateSlider() {
        var age = parseInt(slider.value, 10);
        document.getElementById('sl-age').textContent = age;
        fetch('<%= ctx %>/slider?age=' + age)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                document.getElementById('sl-work').textContent   = data.workdays;
                document.getElementById('ov-date').textContent   = data.targetDate;
                document.getElementById('ov-years').textContent  = data.periodYears;
                document.getElementById('ov-months').textContent = data.periodMonths;
                document.getElementById('ov-days').textContent   = data.periodDays;
                document.getElementById('ov-work').textContent   = data.workdays;
                document.getElementById('dv-total').textContent  = data.daysBetween;
                document.getElementById('dv-biz').textContent    = data.businessDays;
                document.getElementById('dv-we').textContent     = data.weekendDays;
                document.getElementById('dv-hol').textContent    = data.holidays;
                document.getElementById('dv-vac').textContent    = data.vacation;
                document.getElementById('dv-train').textContent  = data.training;
            })
            .catch(function() {});
    }

    slider.addEventListener('input', updateSlider);

    // ---- Settings modal ----
    var settingsLink    = document.getElementById('settingsLink');
    var settingsOverlay = document.getElementById('settingsOverlay');
    var settingsClose   = document.getElementById('settingsClose');
    var settingsForm    = document.querySelector('#settings form');

    function closeSettings() { settingsOverlay.classList.remove('open'); }

    settingsLink.addEventListener('click', function (e) {
        e.preventDefault();
        settingsOverlay.classList.add('open');
    });
    settingsClose.addEventListener('click', closeSettings);
    settingsOverlay.addEventListener('click', function (e) {
        if (e.target === settingsOverlay) closeSettings();
    });
    settingsForm.addEventListener('submit', closeSettings);

    // ---- Panels modal ----
    var panelsLink    = document.getElementById('panelsLink');
    var panelsOverlay = document.getElementById('panelsOverlay');
    var panelsClose   = document.getElementById('panelsClose');

    var panelDefs = [
        { key: 'clock',    hideClass: 'hide-clock',    toggleId: 'panel-toggle-clock' },
        { key: 'overview', hideClass: 'hide-overview', toggleId: 'panel-toggle-overview' },
        { key: 'details',  hideClass: 'hide-details',  toggleId: 'panel-toggle-details' },
        { key: 'age',      hideClass: 'hide-age',      toggleId: 'panel-toggle-age' }
    ];
    var panelPrefs;
    try { panelPrefs = JSON.parse(localStorage.getItem('d2g_panels') || '{}'); }
    catch (e) { panelPrefs = {}; }

    panelDefs.forEach(function (p) {
        var visible = panelPrefs[p.key] !== false;
        var cb = document.getElementById(p.toggleId);
        cb.checked = visible;
        cb.addEventListener('change', function () {
            document.body.classList.toggle(p.hideClass, !cb.checked);
            panelPrefs[p.key] = cb.checked;
            localStorage.setItem('d2g_panels', JSON.stringify(panelPrefs));
        });
    });

    panelsLink.addEventListener('click', function (e) {
        e.preventDefault();
        panelsOverlay.classList.add('open');
    });
    panelsClose.addEventListener('click', function () { panelsOverlay.classList.remove('open'); });
    panelsOverlay.addEventListener('click', function (e) {
        if (e.target === panelsOverlay) panelsOverlay.classList.remove('open');
    });
})();
</script>

</body>
</html>
