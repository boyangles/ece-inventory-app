@Logs = React.createClass
  getInitialState: -> 
    logs: @props.data
  getDefaultProps: ->
    logs: []
  render: ->
    React.DOM.div
      className: 'logs'
      React.DOM.h2
        className: 'title'
        'Logs'
      React.DOM.table
        className: 'table table-bordered'
        React.DOM.thead null,
          React.DOM.tr null,
            React.DOM.th null, 'Time'
            React.DOM.th null, 'User'  
            React.DOM.th null, 'Item Name'
            React.DOM.th null, 'Quantity'  
            React.DOM.th null, 'Status'  
            React.DOM.th null, 'Request Type'  
        React.DOM.tbody null,
          for log in @state.logs
            React.createElement Log, key: log.id, log: log
