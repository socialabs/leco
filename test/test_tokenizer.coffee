{tokenize} = require '../lib/leco'
fs = require 'fs'

read = (x) -> fs.readFileSync(__dirname + '/fixtures/' + x).toString()
f = (x) -> JSON.parse(read(x + '.tok'))
t = (x) -> tokenize(read(x + '.eco'))

module.exports =
    'tokenizing fixtures/hello.eco': (test) ->
        test.deepEqual f('hello'), t('hello')
        test.done()

    'tokenizing fixtures/projects.eco': (test) ->
        test.deepEqual f('projects'), t('projects')
        test.done()

    'tokenizing fixtures/helpers.eco': (test) ->
        test.deepEqual f('helpers'), t('helpers')
        test.done()
