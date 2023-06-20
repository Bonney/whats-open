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
    const address = business.address;
    const phone = business.phone;
    const hours = business.hours;

    let html = `
    <div class="grid grid-rows-2 rounded mb-4">
        <div class="grid grid-cols-3 m-1">
            <div class="text-left font-bold">
               ${name}
            </div>
            <div class="opacity-75 text-right">
                ${phone}
            </div>
            <div class="opacity-75 text-right">
                ${address}
            </div>
        </div>
        <div class="grid grid-cols-7 text-sm bg-gray-50 font-bold border-r">
            <div class="border-t border-l border-gray-200 p-1">
                Mon
            </div>
            <div class="border-t border-l border-gray-200 p-1">
                Tue
            </div>
            <div class="border-t border-l border-gray-200 p-1">
                Wed
            </div>
            <div class="border-t border-l border-gray-200 p-1">
                Thu
            </div>
            <div class="border-t border-l border-gray-200 p-1">
                Fri
            </div>
            <div class="border-t border-l border-gray-200 p-1">
                Sat
            </div>
            <div class="border-t border-l border-gray-200 p-1">
                Sun
            </div>
        </div>
        <div class="grid grid-cols-7 text-sm border-r border-b">
    `;

    let hoursHTML = '';
    for (const day in hours) {
      if (hours.hasOwnProperty(day)) {
        const dayHours = hours[day];
        const formattedHours = dayHours.length > 0 ? formatHours(dayHours) : "Closed";
        hoursHTML += `
        <div class="border-t border-l border-gray-200 p-1">
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
