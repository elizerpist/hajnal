import { mountBottomNavigation } from '../components/bottom-navigation.mjs';

export function mountPageChrome(activeRoute) {
  const host = document.querySelector('[data-component="bottom-navigation-host"]');
  if (!host) throw new Error('Nav-bearing page requires one BottomNav host');
  mountBottomNavigation(host, activeRoute, { rootDocument: activeRoute === 'home' });
}
