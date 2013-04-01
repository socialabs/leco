{tokenize, transform} = require '../lib/leco'
fs = require 'fs'

read = (x) -> fs.readFileSync(__dirname + '/fixtures/' + x).toString()
f = (x) -> read(x + '.coffee')
t = (x) -> transform(tokenize(read(x + '.eco')))

module.exports =
    'transforming fixtures/hello.eco': (test) ->
        test.deepEqual f('hello'), t('hello')
        test.done()

    'transforming fixtures/projects.eco': (test) ->
        test.deepEqual f('projects'), t('projects')
        test.done()

    'transforming fixtures/helpers.eco': (test) ->
        test.deepEqual f('helpers'), t('helpers')
        test.done()
