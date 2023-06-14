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
            ${generateBusinessHTML(restaurant)}
        `;

        tbody.appendChild(details);
    });
  })
  .catch(error => console.error('Error fetching data: ', error));

  function generateBusinessHTML(data) {
    const name = data.name;
    const address = data.address;
    const phone = data.phone;
    const hours = data.hours;
  
    let tableHTML = `
      <table>
        <tr>
          <th colspan="2">${name}</th>
        </tr>
        <tr>
          <td>Address:</td>
          <td>${address}</td>
        </tr>
        <tr>
          <td>Phone:</td>
          <td>${phone}</td>
        </tr>
        <tr>
          <td>Business Hours:</td>
          <td>
            <table>
              <tr>
                <th>Day</th>
                <th>Hours</th>
              </tr>
    `;
  
    // Iterate over the days of the week and their corresponding hours
    for (const day in hours) {
      if (hours.hasOwnProperty(day) && hours[day].length > 0) {
        tableHTML += `
          <tr>
            <td>${capitalizeFirstLetter(day)}</td>
            <td>${formatHours(hours[day])}</td>
          </tr>
        `;
      }
    }
  
    tableHTML += `
            </table>
          </td>
        </tr>
      </table>
    `;
  
    return tableHTML;
  }
  
  // Helper function to capitalize the first letter of a string
  function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }
  
  // Helper function to format the business hours
  function formatHours(hours) {
    return hours.join(", ");
  }
  