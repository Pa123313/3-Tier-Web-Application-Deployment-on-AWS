(async () => {
  const backend = "http://15.207.115.10:5000";
  try {
    const res = await fetch(`${backend}/health`);
    document.getElementById("api").innerText = await res.text();
  } catch (e) {
    document.getElementById("api").innerText = "Backend not reachable yet.";
  }
})();





