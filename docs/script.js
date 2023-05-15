// script.js
fetch('data.json')
  .then(response => response.json())
  .then(data => {
    const tbody = document.getElementById('restaurant-table-body');
    data.forEach((restaurant, index) => {
        const restaurantAddressEncoded = encodeURIComponent(restaurant.address).replace(/%20/g, '+');
        const googleMapsLink = `https://www.google.com/maps/dir/190+New+County+Rd,+Thomaston,+ME+04861/${restaurantAddressEncoded}`;

        const restaurantDetails = document.createElement('tr');
        restaurantDetails.innerHTML = `
            <td colspan="3" class="rest-title">${restaurant.name}</td>
            <td colspan="2">${restaurant.phone}</td>
            <td colspan="2">
                <a href="${googleMapsLink}">${restaurant.address}</a>
            </td>
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
  return html;
}
