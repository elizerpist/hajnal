const NAVIGATION = [
  { route: 'home', href: '../index.html', label: 'Főmenü', icon: '⌂' },
  { route: 'history', href: 'history.html', label: 'Történetem', icon: '▥' },
  { route: 'path', href: 'path.html', label: 'Ösvény', icon: '▤' },
  { route: 'meetings', href: 'meetings.html', label: 'Gyűlések', icon: '♧' },
  { route: 'sponsor', href: 'sponsor.html', label: 'Szponzor', icon: '◯' },
];

const ACTIVE_PARENT = { timeline: 'history', calendar: 'history', 'timeline-event': 'history', milestones: 'home', panic: 'home' };

export function mountBottomNavigation(host, activeRoute, { rootDocument = false } = {}) {
  const selectedRoute = ACTIVE_PARENT[activeRoute] || activeRoute;
  if (!NAVIGATION.some(({ route }) => route === selectedRoute)) throw new Error(`Unknown BottomNav route: ${activeRoute}`);
  host.innerHTML = `<nav class="bottom-nav" data-component="bottom-navigation" aria-label="Fő navigáció">${NAVIGATION.map(({ route, href, label, icon }) => {
    const localHref = rootDocument ? (route === 'home' ? 'index.html' : `pages/${href}`) : href;
    return `<a class="bottom-nav-item" href="${localHref}"${route === selectedRoute ? ' aria-current="page"' : ''}><span aria-hidden="true">${icon}</span><span>${label}</span></a>`;
  }).join('')}</nav>`;
}
