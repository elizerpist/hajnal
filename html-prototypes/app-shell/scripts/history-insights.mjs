export function mountExpandableInsight(root) {
  const trigger = root.querySelector('[data-action="toggle-insight"]');
  if (!trigger) throw new Error('Expandable insight requires its toggle trigger');
  const render = () => trigger.setAttribute('aria-expanded', String(root.dataset.expanded === 'true'));
  trigger.addEventListener('click', () => {
    root.dataset.expanded = String(root.dataset.expanded !== 'true');
    render();
  });
  render();
}
