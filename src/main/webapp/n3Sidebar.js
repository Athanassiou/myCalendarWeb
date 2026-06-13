(function () {
    var hamburger = document.getElementById('hamburger');
    var sidebar   = document.getElementById('sidebar');
    var overlay   = document.getElementById('sidebar-overlay');
    if (hamburger && sidebar && overlay) {
        hamburger.addEventListener('click', function () { sidebar.classList.toggle('open'); overlay.classList.toggle('open'); });
        overlay.addEventListener('click',   function () { sidebar.classList.remove('open'); overlay.classList.remove('open'); });
    }

    (function () {
        var body  = document.body;
        var btn   = document.getElementById('themeToggle');
        var label = document.getElementById('themeLabel');
        if (!btn) return;
        function applyTheme(grey) {
            body.classList.toggle('grey-mode', grey);
            if (label) label.textContent = grey ? 'Dark Mode' : 'Grey Mode';
        }
        applyTheme(localStorage.getItem('n3theme') === 'grey');
        btn.addEventListener('click', function () {
            var g = body.classList.contains('grey-mode');
            applyTheme(!g);
            localStorage.setItem('n3theme', g ? 'dark' : 'grey');
        });
    })();

    (function () {
        var body  = document.body;
        var btn   = document.getElementById('compactToggle');
        var icon  = document.getElementById('compactIcon');
        var label = document.getElementById('compactLabel');
        if (!btn) return;
        function applyCompact(c) {
            body.classList.toggle('compact', c);
            if (icon)  icon.className    = c ? 'fa-solid fa-angles-right' : 'fa-solid fa-angles-left';
            if (label) label.textContent = c ? 'Erweitern' : 'Kompakt';
        }
        applyCompact(localStorage.getItem('n3sidebar') === 'compact');
        btn.addEventListener('click', function () {
            var c = body.classList.contains('compact');
            applyCompact(!c);
            localStorage.setItem('n3sidebar', c ? 'full' : 'compact');
        });
    })();
})();
