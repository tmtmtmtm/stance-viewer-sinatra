
$(document).ready(function() {
    console.log("Ready");

    function make_search_results_movable() { 
      $('#motionList button').click( function(e) {
          // console.log('ID: ' + $(this).parent().attr('id') + ": " + $(this).attr('data'));
          $(this).parent('li').appendTo('#selected-'+$(this).attr('data'));
          // next ... change the decoration when we move
          e.preventDefault();
      });
    }

    function motion_html(id, name) { 
        return $("<li>").attr('id', id).addClass("list-group-item").text(name).append($("<br>")).append(
            $("<button>").attr('type', 'button').attr('data', 'for').addClass("btn btn-primary").text("For")
        ).append(" ").append(
            $("<button>").attr('type', 'button').attr('data', 'against').addClass("btn btn-danger").text("Against")
        );
    }

    make_search_results_movable();
    $("#motion-search-form").submit(function(e) {
        $("ul#motionList").empty().append("... searching");
        $.ajax({
            type: "GET",
            url: "/api/motions",
            data: $("#motion-search-form").serialize(),
            success: function(data) {
                $("ul#motionList").empty();
                jQuery.each(data, function(i, motion) {
                  $("ul#motionList").append( motion_html(motion['id'], motion['text']) );
                  console.log(motion['id'] + ": " + motion['text'])
                });
                make_search_results_movable();
            }
        });
        e.preventDefault();
    });
});


