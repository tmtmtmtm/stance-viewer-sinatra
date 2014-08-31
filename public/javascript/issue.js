
$(document).ready(function() {
    console.log("Ready");

    // TODO make the buttons do something
    function strengthButtonGroup() {
        return $("<div>")
            .addClass("strengthButtons btn-group pull-right")
            .append( $("<label>").addClass("btn btn-default btn-xs").text("Strong") )
            .append( $("<label>").addClass("btn btn-default btn-xs").text("Moderate") );
    }

    function chooseButtonGroup() { 
        return $("<div>").addClass("chooseButtons").append(
          $("<button>").attr('type', 'button').attr('data', 'for').addClass("btn btn-primary").text("For")
        ).append(" ").append(
            $("<button>").attr('type', 'button').attr('data', 'against').addClass("btn btn-danger").text("Against")
        );
    }
  
    function motion_html(id, name) { 
        return $("<li>").attr('id', id).addClass("list-group-item motion").text(name)
          .append( strengthButtonGroup() )
          .append( chooseButtonGroup() );
    }

    
    function make_search_results_movable() { 
      $('.chooseButtons button').click( function(e) {
          var dir = $(this).attr('data');
          console.log("Adding to " + dir);
          var m = $(this).parents('li.motion')
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
                console.log("Have: " + $("#issue-motions li").length );
                // $("#no-motions-yet").hide() 
            }
        });
        e.preventDefault();
    });
});


