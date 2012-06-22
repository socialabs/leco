{tokenize} = require './tokenizer'
{transform, dumpHelpers} = require './transformer'
CoffeeScript = require "coffee-script"


compile = (source, helpers) ->
    tokens = tokenize(source)
    coffee = transform(tokens, helpers)
    CoffeeScript.compile(coffee, bare: true)


printHelpers = (helpers, helpersName) ->
    value = dumpHelpers(helpers, helpersName).join('\n')
    CoffeeScript.compile(value, bare: true)


exports.compile = compile
exports.printHelpers = printHelpers
