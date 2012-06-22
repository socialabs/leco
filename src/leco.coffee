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
        'wrap':
            abbr: 'w'
            default: 'amd'
            help: 'wrapper type (AMD, CommonJS, global)'
        'helpers-name':
            help: 'helpers name for template'
            default: 'helpers'
        'helpers':
            flag: true
            help: 'only output helpers'

wrappers =
    amd:
        begin: 'define(function() { return '
        end: '});'
    commonjs:
        begin: 'module.exports = '
        end: ''
    global:
        begin: '''(function() {
            (this.templates || (this.templates = {}))["%name%"] = '''
        end: '}).call(this);'

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
        wrapper = wrappers[options.wrap.toLowerCase()]
        if not wrapper
            output = "Unknown wrapper: #{wrapper}"
        else
            output = wrapper.begin + output.trim() + wrapper.end;

    if output.indexOf('%name%') != -1
        name = options[0].slice(
            options[0].lastIndexOf('/') + 1,
            options[0].lastIndexOf('.'))
        output = output.replace('%name%', name)

    console.log(output)

run()
