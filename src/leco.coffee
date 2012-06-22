fs = require 'fs'
argumentum = require 'argumentum'
helpers = require './helpers'
compiler = require './compiler'

optConfig =
    script: 'leco'
    commandRequired: no
    options:
        'no-include-helpers':
            abbr: 'n'
            flag: true
            help: 'do not include helpers in template'
        'amd':
            flag: true
            help: 'wrap in AMD'
        'helpers-name':
            help: 'helpers name for template'
            default: 'helpers'
        'helpers':
            flag: true
            help: 'only output helpers'

amdWrap = (template) ->
    stripped = template.trim().replace(/;$/, '')
    return 'define(function() { return ' + stripped + '});';

run = ->
    parser = argumentum.load(optConfig)
    options = parser.parse()
    if options.helpers
        output = compiler.printHelpers(helpers, options['helpers-name'])
    else if not options[0]
        output = parser.getUsage()
    else
        source = fs.readFileSync(options[0]).toString()
        if options['no-include-helpers']
            output = compiler.compile(source)
        else
            output = compiler.compile(source, helpers)
        if options.amd
            output = amdWrap(output)

    console.log(output)

run()
