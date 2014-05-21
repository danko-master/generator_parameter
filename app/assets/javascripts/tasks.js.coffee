$ ->
  $.fn.checkSubmitButton()

  
$.fn.checkSubmitButton =->
  $("#form_select_function").on 'change', ->
    $('.d_functions').hide();
    val = $(this).val();
    id = "#d_" + val
    $(id).show();

  check_submit_button = ->
    if $(".date-start").val().length > 0 && $(".date-stop").val().length > 0
      $("#submit_button").removeAttr("disabled");
    else 
      $("#submit_button").attr("disabled", true);

  check_submit_button()

  $(".date-start, .date-stop").on 'change', ->
    check_submit_button()
  

    