fetch('restaurants-combined.json')
  .then(response => response.json())
  .then(data => {
    const tbody = document.getElementById('restaurant-table-body');
    data.forEach((restaurant, index) => {
      const restaurantAddressEncoded = encodeURIComponent(restaurant.address).replace(/%20/g, '+');
      const googleMapsLink = `https://www.google.com/maps/dir/190+New+County+Rd,+Thomaston,+ME+04861/${restaurantAddressEncoded}`;
      const details = document.createElement('div');
      details.innerHTML = generateHTML(restaurant);
      tbody.appendChild(details);
    });
  })
  .catch(error => console.error('Error fetching data: ', error));

function generateHTML(business) {
    const name = business.name;
    const description = business.description;
    const address = business.address;
    const phone = business.phone;
    const hours = business.hours;

    let html = `
    <div class="flex flex-col p-4 bg-white rounded-lg drop-shadow mb-4">
        <div class="font-bold">
           ${name}
        </div>
        <div class="flex flex-col md:flex-row space-x-0 md:space-x-8 mb-4">
            <div class="text-sm opacity-75">
                ${address}
            </div>
            <div class="text-sm opacity-75">
                ${phone}
            </div>
        </div>
        <div class="grid grid-cols-7 gap-2 text-sm text-left font-bold">
            <div class="bg-white p-1">
                Mon
            </div>
            <div class="bg-white p-1">
                Tue
            </div>
            <div class="bg-white p-1">
                Wed
            </div>
            <div class="bg-white p-1">
                Thu
            </div>
            <div class="bg-white p-1">
                Fri
            </div>
            <div class="bg-white p-1">
                Sat
            </div>
            <div class="bg-white p-1">
                Sun
            </div>
        </div>
        <div class="grid grid-cols-7 gap-2 text-sm text-left">
    `;

    let hoursHTML = '';
    for (const day in hours) {
      if (hours.hasOwnProperty(day)) {
        const dayHours = hours[day];
        const formattedHours = dayHours.length > 0 ? formatHours(dayHours) : "Closed";
        hoursHTML += `
        <div class="bg-white p-1">
            ${formattedHours}
        </div>
        `;
      }
    }

    html += hoursHTML;

    html += `
    </div>
    </div>
    `;

    return html;
}

// Helper function to capitalize the first letter of a string
function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

// Helper function to format the business hours
function formatHours(hours) {
  return hours.join(", ");
}
