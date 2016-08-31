matter = require 'gray-matter'
handlebars = require 'handlebars'
registerHelpers = require 'handlebars-helpers'
registerJustHelpers = require('just-handlebars-helpers').registerHelpers
{allowUnsafeNewFunction, allowUnsafeEval} = loophole = require 'loophole'

module.exports =

  # Atom Package Entry Point
  activate: (state) ->
    atom.packages.onDidActivatePackage (pkg) =>
      if pkg.name is 'markdown-preview-enhanced'
        pkg.mainModule.onWillParseMarkdown (markdown) =>
          @preprocessMarkdown markdown

  deactivate: ->
  # serialize

  # General API
  preprocessMarkdown: (markdown, options={}) ->
    parsed = matter(markdown)
    return markdown unless parsed.data?

    unless options.spreadsheet
      return markdown unless parsed.data.spreadsheet?
      {spreadsheet} = parsed.data

    else
      spreadsheet = parsed.data

    hb = handlebars.create()

    registerHelpers handlebars: hb
    registerJustHelpers hb

    for thing in [ options, spreadsheet ]
      if thing.helpers?
        for name, helper of thing.helpers
          hb.registerHelper name, helper

      if thing.decorators?
        for name, decorator of thing.decorators
          hb.registerDecorator name, decorator

      if thing.partials?
        for name, partial of thing.partials
          hb.registerPartial name, partial

    hb.registerHelper 'calc', (calculation, options) ->
      if (" "+calculation+" ").match(/[^=]=[^=]/)
        throw new Exception("calculation must not contain assignment")

      c = (" "+calculation).replace /([^\w.])(\w+)/g, "$1 data['$2']"
      return eval "data = "+JSON.stringify(this)+";"+c

#    hb.registerHelper 'csv',

    hb.registerHelper 'test', (args...) ->
      options = args.pop()
      content = ''

      if options.fn
        data = {'x': 'y'}
        content = options.fn(data)

      return "test helper\nthis: "+JSON.stringify(this)+"\nargs: "+JSON.stringify(args)+"\noptions: "+JSON.stringify(options)+"\ncontent:\n#{content}"


    content = parsed.content.replace /^\s*/, ''
    content = content.replace /\{\{=([\s\S]*?)\}\}/g, (m, expr) ->
      '{{calc "'+expr.trim()+'"}}'

    allowUnsafeEval ->
      allowUnsafeNewFunction ->
        try
          template = hb.compile content
          template(spreadsheet)
        catch e
          """
          ```
          #{e.stack}
          ```
          """
