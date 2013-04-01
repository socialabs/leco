{tokenize, transform, helpers} = require '../lib/leco'
fs = require 'fs'
CoffeeScript = require 'coffee-script'


read = (x) -> fs.readFileSync(__dirname + '/fixtures/' + x).toString()
f = (x) -> read(x + '.out')
t = (x, ctx) ->
    tokens = tokenize(read(x + '.eco'))
    tpl = transform(tokens, {}, helpers)
    CoffeeScript.eval(tpl)(ctx)


module.exports =
    'transforming fixtures/hello.eco': (test) ->
        test.deepEqual f('hello'), t('hello', name: 'Sam')
        test.done()

    'transforming fixtures/projects.eco': (test) ->
        result = t('projects', projects: [
          { name: "PowerTMS Active Shipments Page Redesign", url: "/projects/1" },
          { name: "SCU Intranet", url: "/projects/2", description: "<p><em>On hold</em></p>" },
          { name: "Sales Template", url: "/projects/3" }
        ])
        test.deepEqual f('projects'), result
        test.done()

    'transforming fixtures/helpers.eco': (test) ->
        result = t('helpers',
            items: [
              { name: "Caprese", price: "5.25"},
              { name: "Artichoke", price: "6.25" }
            ]
            contentTag: (tagName, attributes, callback) ->
                attrs = (" #{name}=\"#{value}\"" for name, value of attributes)
                helpers.safe "<#{tagName}#{attrs.join("")}>#{callback()}</#{tagName}>"
        )
        test.deepEqual f('helpers'), result
        test.done()
