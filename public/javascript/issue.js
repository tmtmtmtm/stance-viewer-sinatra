
$(document).ready(function() {
    console.log("Ready");
    $('#motionList button').click( function(e) {
        // console.log('ID: ' + $(this).parent().attr('id') + ": " + $(this).attr('data'));
        $(this).parent('li').appendTo('#selected-'+$(this).attr('data'));
    });
});


