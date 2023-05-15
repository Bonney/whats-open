const form = document.getElementById('edit-form');

form.addEventListener('submit', (event) => {
  event.preventDefault();

  const name = form.elements.name.value;
  const address = form.elements.address.value;
  const phone = form.elements.phone.value;
  const hours = {
    monday: form.elements.monday.value,
    tuesday: form.elements.tuesday.value,
    wednesday: form.elements.wednesday.value,
    thursday: form.elements.thursday.value,
    friday: form.elements.friday.value,
    saturday: form.elements.saturday.value,
    sunday: form.elements.sunday.value
  };

  // TODO: Update the JSON data file with the new restaurant information

  // Clear the form inputs
  form.reset();
});
