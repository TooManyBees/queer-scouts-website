(function() {
	var emails = {
		river: "bgdileo@gmail.com",
		jess: "hi@toomanybees.com",
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
		elem.addEventListener("auxclick", click);
		elem.addEventListener("keydown", click);
	});
})();
