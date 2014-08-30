
$(document).ready(function() {
    console.log("Ready");
    $('#motionList button').click( function(e) {
        alert('ID: ' + $(this).parent().attr('id') + ": " + $(this).attr('data'));
    });
});


