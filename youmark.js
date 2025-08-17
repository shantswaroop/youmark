// Function to search bookmarks based on a query
function searchBookmarks(query) {
  let bookmarks = JSON.parse(localStorage.getItem("bookmarks")) || [];
  return bookmarks.filter(b => b.title.toLowerCase().includes(query.toLowerCase()));
}

// Function to export bookmarks as a JSON file
function exportBookmarks() {
  let data = localStorage.getItem("bookmarks");
  let blob = new Blob([data], { type: "application/json" });
  let url = URL.createObjectURL(blob);
  let a = document.createElement("a");
  a.href = url;
  a.download = "bookmarks.json";
  a.click();
}

// Function to validate YouTube video URLs
function isValidYouTubeURL(url) {
  return /^https?:\/\/(www\.)?youtube\.com\/watch\?v=/.test(url);
}

// Function to add a bookmark
function addBookmark() {
  let url = document.getElementById("input").value;
  if (!isValidYouTubeURL(url)) {
    alert("Please enter a valid YouTube video URL.");
    return;
  }

  // Extract video ID from the URL
  const videoId = url.split('v=')[1].split('&')[0]; // Handle potential additional parameters
  fetch(`https://www.googleapis.com/youtube/v3/videos?id=${videoId}&key=YOUR_API_KEY&part=snippet`)
    .then(response => {
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      return response.json();
    })
    .then(data => {
      if (data.items.length > 0) {
        let title = data.items[0].snippet.title;
        let thumbnail = data.items[0].snippet.thumbnails.default.url;
        let timestamp = new Date().toISOString();

        // Retrieve existing bookmarks or initialize an empty array
        let bookmarks = JSON.parse(localStorage.getItem("bookmarks")) || [];
        bookmarks.push({ url, title, thumbnail, timestamp });

        // Save bookmarks to local storage
        try {
          localStorage.setItem("bookmarks", JSON.stringify(bookmarks));
          alert("Bookmark added successfully!"); // Confirmation message
        } catch (e) {
          alert("Unable to save bookmark. Try clearing some storage.");
        }
      } else {
        alert("Video not found.");
      }
    })
    .catch(error => {
      console.error("Error fetching video details:", error);
      alert("Failed to fetch video details.");
    });
}

// Initialize bookmarks array
let bookmarks = [];
try {
  bookmarks = JSON.parse(localStorage.getItem("bookmarks")) || [];
} catch (e) {
  console.warn("Could not parse bookmarks:", e);
  localStorage.removeItem("bookmarks"); // Optional reset
}
