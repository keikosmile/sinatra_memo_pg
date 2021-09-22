document.querySelectorAll('.js-table-tbody-tr').forEach(row => {
  row.addEventListener('click', () => {
    location = row.getAttribute('data-href');
  })
});
