MarkdownSpreadsheetView = require './markdown-spreadsheet-view'
{CompositeDisposable} = require 'atom'

module.exports = MarkdownSpreadsheet =
  markdownSpreadsheetView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @markdownSpreadsheetView = new MarkdownSpreadsheetView(state.markdownSpreadsheetViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @markdownSpreadsheetView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-spreadsheet:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @markdownSpreadsheetView.destroy()

  serialize: ->
    markdownSpreadsheetViewState: @markdownSpreadsheetView.serialize()

  toggle: ->
    console.log 'MarkdownSpreadsheet was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
