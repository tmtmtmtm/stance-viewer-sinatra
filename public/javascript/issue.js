
$(document).ready(function() {
    console.log("Ready");
    $('#motionList button').click( function(e) {
        // console.log('ID: ' + $(this).parent().attr('id') + ": " + $(this).attr('data'));
        $(this).parent('li').appendTo('#selected-'+$(this).attr('data'));
        // next ... change the decoration when we move
    });

    $("#motion-search-form").submit(function() {
        $.ajax({
            type: "GET",
            url: "/api/motions",
            data: $("#motion-search-form").serialize(),
            success: function(data) {
                console.log(data);
            }
        });
        return false; 
    });
});


