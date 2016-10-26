function addShowHideDetails() {
  var elements = document.getElementsByClassName('js-show-details');

  for (var i = elements.length - 1; i >= 0; i--) {

    var show_hide_links = elements[i].getElementsByClassName('js-show');
    var details_elements = elements[i].getElementsByClassName('js-details')

    var show_hide_links = elements[i].getElementsByClassName('js-show');

    for (var j = show_hide_links.length - 1; j >= 0; j--) {
      show_hide_links[j].addEventListener('click', function() {
        if(this.innerText.trim().toLowerCase().match('show more')) {
          this.innerText = "Hide";
        } else {
          this.innerText = "Show more";
        }

        for (var k = details_elements.length - 1; k >= 0; k--) {
          details_elements[k].classList.toggle('shown');
        };

        return false;

      })

    };


  };

}


document.addEventListener('DOMContentLoaded', addShowHideDetails)
