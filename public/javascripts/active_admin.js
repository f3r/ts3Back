/* Active Admin JS */
$(function(){
  $(".datepicker").datepicker({dateFormat: 'yy-mm-dd'});

  $(".clear_filters_btn").click(function(){
    window.location.search = "";
    return false;
  });
});

var sendSortRequestOfModel;
sendSortRequestOfModel = function(model_name) {
  var formData;
  formData = $('#' + model_name + ' tbody').sortable('serialize');
  formData += "&" + $('meta[name=csrf-param]').attr("content") + "=" + encodeURIComponent($('meta[name=csrf-token]').attr("content"));
  return $.ajax({
    type: 'post',
    data: formData,
    dataType: 'script',
    url: '/admin/' + model_name + '/sort'
  });
};
jQuery(function($) {
  if ($('body.admin_cities.index').length) {
    $("#cities tbody").disableSelection();
    return $("#cities tbody").sortable({
      axis: 'y',
      cursor: 'move',
      update: function(event, ui) {
        return sendSortRequestOfModel("cities");
      }
    });
  }
  
  if ($('body.admin_currencies.index').length) {
    $("#currencies tbody").disableSelection();
    return $("#currencies tbody").sortable({
      axis: 'y',
      cursor: 'move',
      update: function(event, ui) {
        return sendSortRequestOfModel("currencies");
      }
    });
  }
});