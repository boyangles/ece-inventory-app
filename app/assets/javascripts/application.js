// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks
//= require best_in_place
//= require turbolinks
//= require turbolinks-compatibility
//= require bootstrap-sprockets
//= require bootstrap3-editable/bootstrap-editable
//= require_tree .
//= require bootstrap-tagsinput
//= require bootstrap-datepicker
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.es.js
//= require bootstrap-datepicker/locales/bootstrap-datepicker.fr.js

$(document).on('ready page:load', function () {
    /* Activating Best In Place */
    $(".best_in_place").best_in_place();
});
