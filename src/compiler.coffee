{tokenize} = require './tokenizer'
{transform} = require './transformer'
CoffeeScript = require "coffee-script"


compile = (source) ->
    tokens = tokenize(source)
    coffee = transform(tokens)
    CoffeeScript.compile(coffee, bare: true)


if process.argv[2]
    f = require('fs').readFileSync(process.argv[2]).toString()
    console.log(compile(f))
