(() => {
  const filters = document.querySelector('.filters');
  if (!filters) return;
  const buttons = Array.from(filters.querySelectorAll('[data-filter]'));
  const cards = Array.from(document.querySelectorAll('.project[data-category]'));
  const status = document.getElementById('filter-status');

  const showCategory = (category, announce = true) => {
    let count = 0;
    for (const card of cards) {
      card.hidden = category !== 'all' && !card.dataset.category.split(' ').includes(category);
      if (!card.hidden) count += 1;
    }
    for (const button of buttons) {
      button.setAttribute('aria-pressed', String(button.dataset.filter === category));
    }
    if (announce) status.textContent = `${count} recent ${count === 1 ? 'project' : 'projects'} shown.`;
  };

  const revealTarget = () => {
    const target = cards.find(card => '#' + card.id === location.hash);
    if (target?.hidden) {
      showCategory('all', false);
      target.scrollIntoView();
    }
  };

  for (const button of buttons) {
    button.addEventListener('click', () => showCategory(button.dataset.filter));
  }
  filters.hidden = false;
  window.addEventListener('hashchange', revealTarget);
  document.addEventListener('click', event => {
    const link = event.target.closest('a[href^="#"]');
    if (link && cards.some(card => card.hidden && '#' + card.id === link.hash)) showCategory('all', false);
  });
})();
