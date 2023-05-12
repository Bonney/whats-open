// script.js
fetch('data.json')
  .then(response => response.json())
  .then(data => {
    const tbody = document.getElementById('restaurant-table-body');
    data.forEach((restaurant, index) => {

        const restaurantDetails = document.createElement('tr');
        restaurantDetails.innerHTML = `
            <td colspan="3">${restaurant.name}</td>
            <td colspan="2">${restaurant.phone}</td>
            <td colspan="2">${restaurant.address}</td>
        `;

        tbody.appendChild(restaurantDetails);

        const restaurantHours = document.createElement('tr');
        restaurantHours.innerHTML = `
           ${formatHours(restaurant.hours)}
        `;

        tbody.appendChild(restaurantHours);
        tbody.appendChild(document.createElement('p'));
    });
  })
  .catch(error => console.error('Error fetching data: ', error));

function formatHours(hours) {
    let html = ``;
  for (const day in hours) {
    html += `<td>${day}<br>${hours[day]}</td>`;
  }
//   html += `</tr>`;
//   html += `<tr>`;
//   for (const day in hours) {
//     html += `<td> ${hours[day]}</td>`;
//   }
  return html;
}
