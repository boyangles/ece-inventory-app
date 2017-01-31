@Logs = React.createClass
  getInitialState: -> 
    logs: @props.data

  getDefaultProps: ->
    logs: []

  addLog: (log) ->
    logs = @state.logs.slice()
    logs.push log
    @setState logs: logs
 
  render: ->
    React.DOM.div
      className: 'logs'
      React.DOM.h2
        className: 'title'
        'Logs'
      React.createElement LogForm, handleNewLog: @addLog
      React.DOM.hr null  
      React.DOM.table
        className: 'table table-bordered'
        React.DOM.thead null,
          React.DOM.tr null,
            React.DOM.th null, 'Time'
            React.DOM.th null, 'Username'  
            React.DOM.th null, 'Item Name'
            React.DOM.th null, 'Quantity'  
            React.DOM.th null, 'Request Type'  
        React.DOM.tbody null,
          for log in @state.logs
            React.createElement Log, key: log.id, log: log
