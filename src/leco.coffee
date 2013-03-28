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
            help: 'name of object containing helper functions'
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
        return compiler.printHelpers(helpers, options['helpers-name'])

    if not options[0]
        return parser.getUsage()

    replaceName = (s) ->
        if s.indexOf('%name%') == -1
            return s
        name = options[0]
        name = name.slice(name.lastIndexOf('/') + 1, name.lastIndexOf('.'))
        return s.replace('%name%', name)

    source = fs.readFileSync(options[0]).toString()

    if options['no-include-helpers']
        template = compiler.compile(source)
    else
        template = compiler.compile(source, helpers)

    wrapper = wrappers[options.wrap.toLowerCase()]
    if not wrapper
        return "Unknown wrapper: #{wrapper}"

    return replaceName(wrapper.begin) + template.trim() + wrapper.end;


console.log(run())
