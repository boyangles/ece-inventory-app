$(document).on "page:change", -> 
	$('#search-link').click (event) ->
		event.preventDefault()
		$('.advanced-search').slideToggle()
