

function addPretendPopups() {

  var elements = document.getElementsByClassName('pretend');

  for (var i = elements.length - 1; i >= 0; i--) {

    elements[i].addEventListener('click', function(event) {

      var reason = this.getAttribute('data-reason');

      alert(reason);

      event.preventDefault();
      return false
    });

  };


}

document.addEventListener('DOMContentLoaded', addPretendPopups)