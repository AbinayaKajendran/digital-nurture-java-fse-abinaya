console.log("Welcome to Community Portal");

window.onload = function () {
    alert("Community Portal Loaded");
};

class Event {
    constructor(name, category, seats) {
        this.name = name;
        this.category = category;
        this.seats = seats;
    }

    checkAvailability() {
        return this.seats > 0 ? "Available" : "Full";
    }
}

const events = [
    new Event("Music Night", "Music", 50),
    new Event("Food Festival", "Food", 30),
    new Event("Coding Workshop", "Workshop", 20)
];

function displayEvents() {

    const container =
        document.getElementById("eventContainer");

    events.forEach(event => {

        const card =
            document.createElement("div");

        card.innerHTML = `
        <h3>${event.name}</h3>
        <p>${event.category}</p>
        <p>${event.checkAvailability()}</p>
        <button onclick="registerUser('${event.name}')">
        Register
        </button>
        <hr>
        `;

        container.appendChild(card);
    });
}

function registerUser(eventName) {
    alert("Registered for " + eventName);
}

function addEvent(name, category, seats) {
    events.push(
        new Event(name, category, seats)
    );
}

function filterEventsByCategory(category) {

    return events.filter(
        event => event.category === category
    );
}

document
.getElementById("registrationForm")
.addEventListener("submit", function (e) {

    e.preventDefault();

    const name =
        document.getElementById("name").value;

    const email =
        document.getElementById("email").value;

    const eventType =
        document.getElementById("eventType").value;

    alert(
        `Name: ${name}
Email: ${email}
Event: ${eventType}`
    );
});

function findNearbyEvents() {

    if (navigator.geolocation) {

        navigator.geolocation.getCurrentPosition(

            function (position) {

                document.getElementById(
                    "location"
                ).innerHTML =

                "Latitude: " +
                position.coords.latitude +
                "<br>Longitude: " +
                position.coords.longitude;
            },

            function () {

                alert(
                    "Location access denied"
                );
            }
        );
    }
}

async function loadData() {

    try {

        const response =
            await fetch(
                "https://jsonplaceholder.typicode.com/posts"
            );

        const data =
            await response.json();

        console.log(data);

    } catch (error) {

        console.log(error);
    }
}

loadData();

displayEvents();
