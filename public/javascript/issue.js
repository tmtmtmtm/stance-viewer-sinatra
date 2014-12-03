
$(document).ready(function() {
    console.log("Ready");
    $("#issueSection").hide();
    $("#motionSection").hide();
    $("#saveSection").hide();



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

    function indicatorDescription() { 
        return $("<div>")
            .addClass("indicatorDescription")
            .append( $("<input>", { type: 'text', name: 'indesc', placeholder: 'motion summary', size: 180 }) )
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
        )
        .append( indicatorDescription() )
        .append( strengthButtonGroup() )
        .append( chooseButtonGroup() );
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
          m.find('.indicatorDescription').show();
          $("#issue-motions li").length > 0 ? $("#no-motions-yet").hide() : $("#no-motions-yet").show();
          e.preventDefault();
      });
    }

  // TODO all the hide()/show() stuff should be based on classes that say
  // which things they appear in, rather than called by name
    $("#newIssueButton").click(function(e) { 
      console.log("New Issue!");
      $("#editorChoice").hide();
      $("#creatorChoice button").hide();
      $("#issueSection").show();
      $("#motionSection").show();
      $("#saveSection").show();
      e.preventDefault();
    });

    $("#loadIssuesButton").click(function(e) { 
      console.log("New Issue!");
      $.ajax({
          type: "GET",
          url: "/api/issues",
          // TODO: failure
          success: function(data) {
              $("ul#issueList").empty();
              // TODO: zero results
              jQuery.each(data, function(i, issue) {
                  var link = $("<a>", { text: issue['text'], href: "#" }).click(function(e) {
                      console.log("Clicked " + issue['id']);
                      console.log(issue);
                      $("#issueSection").show();
                      $("#editorChoice").hide();
                      $("#issueEditor #title").val(issue['text']);
                      $("#issueEditor #description").val(issue['html']);
                      $("#issueEditor #categories").val(issue['categories'].join(", "));
                      // TODO add indicators
                      $("#motionSection").show();
                      $("#saveSection").show();
                      e.preventDefault();
                  });
                  $("ul#issueList").append($("<li>").append(link));
              });
          }
      });
      $("#creatorChoice").hide();
      $("#editorChoice button").hide();
      $("#editorChoice span.label").text("1");
      e.preventDefault();
    });

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
                  $("ul#motionList li .indicatorDescription").hide();
                });
                make_search_results_movable();
            }
        });
        e.preventDefault();
    });
});


