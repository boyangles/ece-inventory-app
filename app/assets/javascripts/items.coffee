# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$ ->
# enable chosen js
  $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    width: '100%'


$(document).getElementById('fuck_you').value
$('#fuck_you').trigger('chosen:updated');

$(document).on "page:change", ->
	heyy = $('#quantity_change')
	quantityA = $('.quantity-A').val()
	quantityB = $('.quantity-B').val()
	change = heyy.val()
	currenttotal = + +quantityA + +quantityB
	$('.display-new-total').val("Current Quantity Total: " + currenttotal)

	heyy.change ->
		if(heyy.val())
			$('.quantity_reason').show()
			change = $('.quantity-change').val()
			newtotal = +quantityA + +quantityB + +change
			$('.display-new-total').val("New Quantity Total: " + newtotal)
		else
			$('.quantity_reason').hide()
			$('.display-new-total').val("Current Quantity Total: " + currenttotal)


$(document).on "page:change", ->
	$('#submit').click (event) ->
		if ($('#quantity_change').val())
			r = confirm("Are you sure you want to edit the quantity?")
			if (r == false)
				event.preventDefault()

