$ ->
  $("#form_select_function").on 'change', ->
    $('.d_functions').hide();
    val = $(this).val();
    id = "#d_" + val
    $(id).show();

  $(".date-start, .date-stop").on 'change', ->
    if $(".date-start").val().length > 0 && $(".date-stop").val().length > 0
      $("#submit_button").removeAttr("disabled");

  if $(".date-start").val().length > 0 && $(".date-stop").val().length > 0
    $("#submit_button").removeAttr("disabled");
    