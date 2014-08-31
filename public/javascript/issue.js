
$(document).ready(function() {
    console.log("Ready");

    // TODO store the selected value
    function strengthButtonGroup() {
        return $("<div>")
            .addClass("strengthButtons btn-group pull-right")
            .append( $("<label>").addClass("strong-aspect btn btn-default btn-xs").text("Strong").click(function() {
              $(this).css({backgroundColor: 'green'});
              $(this).siblings().css({backgroundColor: ''});
            } ))
            .append( $("<label>").addClass("moderate-aspect btn btn-default btn-xs").text("Moderate").click(function() {
              $(this).css({backgroundColor: 'green'});
              $(this).siblings().css({backgroundColor: ''});
            } ));
    }

    function chooseButtonGroup() { 
        return $("<div>").addClass("chooseButtons").append(
          $("<button>").attr('type', 'button').attr('data', 'for').addClass("btn btn-primary").text("For")
        ).append(" ").append(
            $("<button>").attr('type', 'button').attr('data', 'against').addClass("btn btn-danger").text("Against")
        );
    }
  
    function motion_html(motion) { 
        var pwurl = motion['id'].replace('pw-', 'http://www.publicwhip.org.uk/division.php?date=').replace(/\-(\d+)$/,"&number=$1");
        return $("<li>").attr('id', motion['id']).addClass("list-group-item motion").append(
            $("<span>").append(motion['text'] + " ").append( $("<a>", { text: '§', target: "_blank", href: pwurl }) )
        ).append( strengthButtonGroup() ).append( chooseButtonGroup() );
    }

    
    function make_search_results_movable() { 
      $('.chooseButtons button').click( function(e) {
          var dir = $(this).attr('data');
          var m = $(this).parents('li.motion')
          m.appendTo('#selected-'+dir);
          m.prepend( $("<span>").addClass("glyphicon glyphicon-minus-sign actionable").click(function(e) { 
            $(this).parents('li.motion').remove();
          }));
          m.find('button').hide();
          m.find('.strengthButtons').show();
          $("#issue-motions li").length > 0 ? $("#no-motions-yet").hide() : $("#no-motions-yet").show();
          e.preventDefault();
      });
    }

    $("#motion-search-form").submit(function(e) {
        $("ul#motionList").empty().append("... searching");
        $.ajax({
            type: "GET",
            url: "/api/motions",
            data: $("#motion-search-form").serialize(),
            // TODO: failure
            success: function(data) {
                $("ul#motionList").empty();
                // TODO: zero results
                jQuery.each(data, function(i, motion) {
                  $("ul#motionList").append( motion_html(motion) );
                  $("ul#motionList li .strengthButtons").hide();
                });
                make_search_results_movable();
            }
        });
        e.preventDefault();
    });
});


