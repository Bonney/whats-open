// script.js

fetch('data.json')
  .then(response => response.json())
  .then(data => {
    const tbody = document.getElementById('restaurant-table-body');
    data.forEach((restaurant, index) => {
        const restaurantAddressEncoded = encodeURIComponent(restaurant.address).replace(/%20/g, '+');
        const googleMapsLink = `https://www.google.com/maps/dir/190+New+County+Rd,+Thomaston,+ME+04861/${restaurantAddressEncoded}`;

        const details = document.createElement('div');
        details.innerHTML = `
            <hr>
            ${name(restaurant)}
            ${description(restaurant)}
            ${address(restaurant)}
        `;

        tbody.appendChild(details);

        const restaurantHours = document.createElement('div');
        restaurantHours.innerHTML = `
            ${formatHours(restaurant.hours)}
        `;
        tbody.appendChild(restaurantHours);

    });
  })
  .catch(error => console.error('Error fetching data: ', error));

function name(restaurant) {
    let html = `<h3>${restaurant.name}</h3>`
    return html
}

function description(restaurant) {
    let html = `<p>${restaurant.description}</p>`
    return html
}

function address(restaurant) {
    let html = `<p>${restaurant.address}</p>`
    return html
}

function formatHours(hours) {
    let html = `<small>`;

    // Weekday names
    html += `<div class="row">`;
    for (const day in hours) {
        html += `<div class="col">`;
        html += `${day}`;
        html += `</div>`;
    }
    html += `</div>`;

    // Actual hours
    html += `<div class="row">`;
    for (const day in hours) {
        html += `<div class="col">`;
        html += `${hours[day]}`;
        html += `</div>`;
    }
    html += `</div>`;

    // for (const day in hours) {
    //     html += `<td>`;
    //     html += `${day}`;
    //     html += `<hr>`;
    //     html += `${hours[day]}`;
    //     html += `</td>`;
    // }

    html += `</small>`;
    return html;
}
