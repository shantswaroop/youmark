<!DOCTYPE html>
<html lang="en
            <input type="text" id="input" placeholder="Enter YouTube video URL">                                                                                                            
<head>
  <meta charset="UTF-8" />
  <title>YouTube Video Bookmark Tool</title>
  <style>
    body {
      background-color: white;
      font-family: Arial, sans-serif;
      margin: 20px;
    }
    h1 {
      color: red;
      text-align: center;
    }
    input[type="text"] {
      width: 80%;
      padding: 10px;
      border: 2px solid red;
      border-radius: 4px;
      font-size: 16px;
    }
    button {
      background-color: red;
      color: white;
      padding: 10px 15px;
      border: none;
      border-radius: 4px;
      font-size: 16px;
      cursor: pointer;
      margin-left: 10px;
    }
    button:hover {
      background-color: darkred;
    }
    #bookmarkList {
      margin-top: 30px;
    }
    .video-item {
      margin-bottom: 15px;
    }
    iframe {
      width: 100%;
      height: 315px;
    }
    .dark-mode {
      background-color: #333;
      color: white;
    }
  </style>
</head>
<body>
  <h1>YouTube Video Bookmarker</h1>
  <div style="text-align: center;">
    <input type="text" id="videoUrl" placeholder="Enter YouTube URL" />
    <button onclick="addVideo()">Bookmark Video</button>
    <button onclick="toggleDarkMode()">Toggle Dark Mode</button>
  </div>
  
  <div id="bookmarkList"></div>
  
  <script>
    let videos = [];
    let darkMode = false;

    // Load saved videos from localStorage
    window.onload = function() {
      const storedVideos = localStorage.getItem('youtubeBookmarks');
      if (storedVideos) {
        videos = JSON.parse(storedVideos);
        displayVideos();
      }
    }

    function saveToStorage() {
      localStorage.setItem('youtubeBookmarks', JSON.stringify(videos));
    }

    function addVideo() {
      const url = document.getElementById('videoUrl').value.trim();
      if (!url) {
        alert('Please enter a YouTube URL.');
        return;
      }

      if (!url.includes('youtube.com/watch') && !url.includes('youtu.be/')) {
        alert('Please enter a valid YouTube URL.');
        return;
      }

      // Avoid duplicates
      if (videos.includes(url)) {
        alert('This video is already bookmarked.');
        return;
      }

      videos.push(url);
      document.getElementById('videoUrl').value = ''; // Clear input field
      saveToStorage();
      displayVideos();
    }

    function displayVideos() {
      const listDiv = document.getElementById('bookmarkList');
      listDiv.innerHTML = '';

      videos.forEach((videoUrl, index) => {
        const videoId = extractVideoID(videoUrl);
        if (videoId) {
          const videoDiv = document.createElement('div');
          videoDiv.className = 'video-item';
          videoDiv.innerHTML = `
            <iframe src="https://www.youtube.com/embed/${videoId}" frameborder="0" allowfullscreen></iframe>
            <button onclick="removeVideo(${index})" style="margin-top:5px;">Remove</button>
          `;
          listDiv.appendChild(videoDiv);
        } else {
          const fallbackDiv = document.createElement('div');
          fallbackDiv.innerHTML = `
            <p>Invalid YouTube URL: ${videoUrl}</p>
            <button onclick="removeVideo(${index})" style="margin-top:5px;">Remove</button>
          `;
          listDiv.appendChild(fallbackDiv);
        }
      });
    }

    function extractVideoID(url) {
      const regex = /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|embed)\/|.*[?&]v=)|youtu\.be\/)([^\s&?/]+)/;
      const match = url.match(regex);
      return match ? match[1] : null;
    }

    function removeVideo(index) {
      videos.splice(index, 1);
      saveToStorage();
      displayVideos();
    }

    function toggleDarkMode() {
      darkMode = !darkMode;
      document.body.classList.toggle('dark-mode', darkMode);
    }
  </script>
</body>
</html>
.bookmark-item {
  background: #fff;
  border: 2px solid #000;
  padding: 10px;
  transition: transform 0.2s ease;
}
.bookmark-item:hover {
  transform: scale(1.05);
  border-color: red;
}
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
