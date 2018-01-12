// ==UserScript==
// @name 		luna/l/ catalog
// @namespace 	https://niles.xyz
// @include 	http://lunaboards.xyz/*
// @include 	https://lunaboards.xyz/*
// @version		1.0
// @grant 		GM_getValue
// @grant 		GM_setValue
// @run-at 		document-end
// ==/UserScript==
var started = false;
var onload = function () {

	// Only start once
	if (started) {
		return;
	}
	started = true;

	var href = document.location.href;
	//var board = href.substr(href.lastIndexOf("/") + 1);
	var as = document.getElementsByTagName("a");
	for (var i = 0; i < as.length; i++) {
		var a = as[i];
		if (!a.hasAttribute("x-data-length")) {
			continue;
		}

		var board = a.href.split("/")[3];
		var id = a.href.split("/")[4];

		var elem = document.createElement("span");
		a.appendChild(elem);
		elem.innerHTML = "Loading...";

		var key = board + ":" + id;
		var oldreplies = GM_getValue(key, 0);
		var replies = Number(a.getAttribute("data-length"));
		comparison_and_update_elem(key, replies, a, elem, closed, oldreplies);
	}

};

var grey = function grey(text) {
	return color("grey", text);
};
var red = function red(text) {
	return color("red", text);
};
var color = function color(c, text) {
	return " <span style='color: " + c + ";'>" + text + "</span>";
};

var comparison_and_update_elem = function(key, replies, a, elem, closed, oldreplies) {
	if (oldreplies < replies) {
		elem.innerHTML = red("+" + (replies - oldreplies));
		// we have to wrap this in a closure because otherwise it clicking any post would only update the last post processed in this loop
		set_onclick_listener(key, replies, a, elem, closed);
	} else {
		elem.innerHTML = grey(replies);
	}
};

var set_onclick_listener = function set_onclick_listener(key, replies, a, elem, closed) {
	console.log(key);
	a.addEventListener("click", function() {
		GM_setValue(key, replies);
		elem.innerHTML = grey(replies);
	});
};


// In chrome, the userscript runs in a sandbox, and will never see these events
// Hence the run-at document-end
//document.addEventListener('DOMContentLoaded', onload);
//document.onload = onload;

// One of these should work, and the started variable should prevent it from starting twice (I hope)
function GM_main() {
	onload();
}
onload();

