$(document).on "page:change", -> 
	$('#search-link').click (event) ->
		event.preventDefault()
		$('.advanced-search').slideToggle()

$(document).on "page:change", -> 
	$('#search-log-link').click (event) ->
		event.preventDefault()
		$('.search-loans').slideToggle()

