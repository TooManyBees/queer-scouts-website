(function() {
	var emails = {
		river: "nope@example.com",
		jess: "nope@example.com",
	};
	var mails = document.querySelectorAll('a[data-email]');
	function click(event) {
		var elem = event.target;
		var name = elem.dataset.email;
		var email = emails[name];
		if (email) {
			elem.setAttribute("href", "mailto:" + email);
			elem.removeEventListener("click", click);
		} else {
			event.preventDefault();
		}
	}
	Array.prototype.forEach.call(mails, function(elem) {
		elem.addEventListener("click", click);
	});
})();
