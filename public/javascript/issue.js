
$(document).ready(function() {
    console.log("Ready");

    // TODO make the buttons do something
    function strengthButtonGroup(direction) {
        return '<div class="btn-group pull-right">' +
            '<label class="btn btn-default btn-xs" btn-radio="2">Strongly ' + direction + '</label>' +
            '<label class="btn btn-default btn-xs" btn-radio="1">Moderately ' + direction + '</label>' +
          '</div>';
    }
  

    function make_search_results_movable() { 
      $('#motionList button').click( function(e) {
          var dir = $(this).attr('data');
          // console.log('ID: ' + $(this).parent().attr('id') + ": " + dir);
          var m = $(this).parent('li')
          m.appendTo('#selected-'+dir);
          m.prepend( $("<span>").addClass("glyphicon glyphicon-minus-sign actionable").text(" "));
          m.children('button').remove();
          m.children('br').remove();
          m.append(strengthButtonGroup(dir));
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


