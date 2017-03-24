# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:change", ->
	$('.users-items-display-link').click (event) ->
		event.preventDefault()
		$(this).next().slideToggle()

$(document).on "page:change", -> 
	$('.users-request-display-link').click (event) ->
		event.preventDefault()
		$(this).next().slideToggle()


