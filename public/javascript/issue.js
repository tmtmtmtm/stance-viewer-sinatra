
$(document).ready(function() {
    console.log("Ready");

    // TODO make the buttons do something
    function strengthButtonGroup(direction) {
        return $("<div>").addClass("strengthButtons btn-group pull-right").append(
          $("<label>").addClass("btn btn-default btn-xs").text("Strong")
        ).append(
          $("<label>").addClass("btn btn-default btn-xs").text("Moderate")
        );
    }
  
    function motion_html(id, name) { 
        return $("<li>").attr('id', id).addClass("list-group-item").text(name).append(strengthButtonGroup('for')).append($("<br>")).append(
            $("<button>").attr('type', 'button').attr('data', 'for').addClass("btn btn-primary").text("For")
        ).append(" ").append(
            $("<button>").attr('type', 'button').attr('data', 'against').addClass("btn btn-danger").text("Against")
        );
    }

    
    function make_search_results_movable() { 
      $('#motionList button').click( function(e) {
          var dir = $(this).attr('data');
          var m = $(this).parent('li')
          m.appendTo('#selected-'+dir);
          m.prepend( $("<span>").addClass("glyphicon glyphicon-minus-sign actionable").text(" "));
          m.find('button').hide();
          m.find('.strengthButtons').show();
          e.preventDefault();
      });
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
                  $("ul#motionList li .strengthButtons").hide();

                  console.log(motion['id'] + ": " + motion['text'])
                });
                make_search_results_movable();
            }
        });
        e.preventDefault();
    });
});


