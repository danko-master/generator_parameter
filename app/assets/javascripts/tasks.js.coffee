$ ->
  $.fn.checkSubmitButton()
  $.fn.drawGraph()

  
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

$.fn.drawGraph = ()->
  #Функция рисует картинку после загрузки страницы
  draw = () -> 
    Morris.Line
      element: "graph_tasks"
      data: $("#param_val_chart").data('param-vals')
      xkey: "date_time"
      ykeys: ["val_numeric"]
      labels: [
        "Параметр"
      ]
      lineColors: [
        "#167f39"
      ]
      lineWidth: 2

    Morris.Line
      element: "graph_infos"
      data: $("#val_chart").data('vals')
      xkey: "date_time"
      ykeys: ["val_numeric", 
      "param_level_down_level", 
      "param_preset_down_preset", 
      "param_preset_up_preset", 
      "param_level_up_level"]
      labels: [
        "Значение", "Нижний диапазон", "Нижняя уставка", "Верхняя уставка", "Верхний диапазон"
      ]
      lineColors: [
        "#167f39",'#f82a2a','#e9e900','#bf49c4','#f66a0c'
      ]
      lineWidth: 1

  draw()
  

    