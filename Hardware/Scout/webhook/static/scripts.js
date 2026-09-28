function sendMoveRequest(linear_z, angular_z, message) {
  console.log("sendMoveRequest called with:", linear_z, angular_z);
  fetch("http://127.0.0.1:5001/move", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      linear_z: linear_z,
      angular_z: angular_z,
    }),
  })
    .then((response) => response.json())
    .then((data) => {
      console.log("Response from /move:", data);
      updateStatusMessage(message);
      checkAutoShot();
    })
    .catch((error) => {
      console.error("Error:", error);
      updateStatusMessage("Error: " + error.message);
    });
}

function updateStatusMessage(message) {
  console.log("updateStatusMessage called with:", message);
  const statusMessageDiv = document.getElementById("status-message");
  statusMessageDiv.textContent = message;
}

function checkAutoShot() {
  const autoShotCheckbox = document.getElementById("auto-shot");
  if (autoShotCheckbox.checked) {
    takeScreenshot();
  }
}

function takeScreenshot() {
  fetch("http://127.0.0.1:5001/screenshot")
    .then((response) => response.json())
    .then((data) => {
      console.log("Screenshot taken:", data);
      if (data.success) {
        updateStatusMessage("Screenshot taken automatically");
        const imageUrl = "/static/" + data.filename;
        document.getElementById("camera_image").src = imageUrl;
      } else {
        updateStatusMessage(data.message);
      }
    })
    .catch((error) => {
      console.error("Error taking screenshot:", error);
      updateStatusMessage("Error taking screenshot: " + error.message);
    });
}
