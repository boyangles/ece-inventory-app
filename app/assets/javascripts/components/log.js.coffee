@Log = React.createClass
  render: ->
    React.DOM.tr null,
      React.DOM.td null, @props.log.datetime
      React.DOM.td null, @props.log.user
      React.DOM.td null, @props.log.item_name
      React.DOM.td null, @props.log.quantity
      React.DOM.td null, @props.log.status
      React.DOM.td null, @props.log.request_type
