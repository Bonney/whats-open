// script.js
fetch('data.json')
  .then(response => response.json())
  .then(data => {
    const tbody = document.getElementById('restaurant-table-body');
    data.forEach((restaurant, index) => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${index + 1}</td>
        <td>${restaurant.name}</td>
        <td>${restaurant.address}</td>
        <td>${restaurant.phone}</td>
        <td>${formatHours(restaurant.hours)}</td>
      `;
      tbody.appendChild(tr);
    });
  })
  .catch(error => console.error('Error fetching data: ', error));

function formatHours(hours) {
  let html = '<ul>';
  for (const day in hours) {
    html += `<li>${day}: ${hours[day]}</li>`;
  }
  html += '</ul>';
  return html;
}
