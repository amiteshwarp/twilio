document.addEventListener('DOMContentLoaded', function() {
    // Tab functionality
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabPanes = document.querySelectorAll('.tab-pane');

    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            // Remove active class from all buttons and panes
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabPanes.forEach(pane => pane.classList.remove('active'));

            // Add active class to clicked button and corresponding pane
            button.classList.add('active');
            const tabId = button.getAttribute('data-tab');
            document.getElementById(tabId).classList.add('active');
        });
    });

    // Image gallery functionality
    const mainImage = document.querySelector('.main-image img');
    const thumbnails = document.querySelectorAll('.thumbnail-grid img');

    thumbnails.forEach(thumb => {
        thumb.addEventListener('click', () => {
            mainImage.src = thumb.src;
            mainImage.alt = thumb.alt;
        });
    });
});

// Random data generation for property details
function generateRandomData() {
    const prices = [1800, 2200, 2800, 3200, 3800]; // Utah-specific price ranges
    const beds = [1, 2, 3];
    const baths = [1, 2];
    const sqft = [800, 1000, 1200, 1500];
    const availability = ['Available Now', 'Available in 2 weeks', 'Available in 1 month'];
    const locations = [
        'Downtown Salt Lake City',
        'Sugar House',
        'The Avenues',
        'Liberty Park'
    ];

    return {
        price: prices[Math.floor(Math.random() * prices.length)],
        beds: beds[Math.floor(Math.random() * beds.length)],
        baths: baths[Math.floor(Math.random() * baths.length)],
        sqft: sqft[Math.floor(Math.random() * sqft.length)],
        availability: availability[Math.floor(Math.random() * availability.length)],
        location: locations[Math.floor(Math.random() * locations.length)]
    };
}

// Update property details with random data
function updatePropertyDetails() {
    const data = generateRandomData();
    
    // Update price
    const priceElement = document.querySelector('.property-meta span:nth-child(2)');
    if (priceElement) {
        priceElement.innerHTML = `<i class="fas fa-tag"></i> $${data.price}/month`;
    }

    // Update location
    const locationElement = document.querySelector('.property-meta span:nth-child(1)');
    if (locationElement) {
        locationElement.innerHTML = `<i class="fas fa-map-marker-alt"></i> ${data.location}, Salt Lake City, UT`;
    }

    // Update beds
    const bedsElement = document.querySelector('.detail-item:nth-child(1) span');
    if (bedsElement) {
        bedsElement.textContent = `${data.beds} Beds`;
    }

    // Update baths
    const bathsElement = document.querySelector('.detail-item:nth-child(2) span');
    if (bathsElement) {
        bathsElement.textContent = `${data.baths} Baths`;
    }

    // Update sqft
    const sqftElement = document.querySelector('.detail-item:nth-child(3) span');
    if (sqftElement) {
        sqftElement.textContent = `${data.sqft} sq ft`;
    }

    // Update availability
    const availabilityElement = document.querySelector('.detail-item:nth-child(4) span');
    if (availabilityElement) {
        availabilityElement.textContent = data.availability;
    }
}

// Call the function to update property details
updatePropertyDetails(); 