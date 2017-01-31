@Log = React.createClass
  render: ->
    React.DOM.tr null,
      React.DOM.td null, @props.log.datetime
      React.DOM.td null, @props.log.user.username
      React.DOM.td null, @props.log.item.unique_name
      React.DOM.td null, @props.log.quantity
      React.DOM.td null, @props.log.request_type
