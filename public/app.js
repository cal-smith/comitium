function toggle () {
	var state = document.getElementById('new-post').style.display;
	document.getElementById('new-post').style.display = state === "block" ? "none" : "block";
}