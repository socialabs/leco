{tokenize} = require './tokenizer'
{transform, dumpHelpers} = require './transformer'
CoffeeScript = require 'coffee-script'


compile = (source, options={}) ->
    tokens = tokenize(source)
    coffee = transform(tokens, options)
    CoffeeScript.compile(coffee, bare: true)


printHelpers = (helpers, helpersName) ->
    value = dumpHelpers(helpers, helpersName).join('\n')
    CoffeeScript.compile(value, bare: true)


exports.compile = compile
exports.printHelpers = printHelpers
