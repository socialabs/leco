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


wrap = (name, template, path) ->
    wrapper = wrappers[name.toLowerCase()]
    if not wrapper
        return "Unknown wrapper: #{wrapper}"

    begin = wrapper.begin
    if begin.indexOf('%name%') != -1
        tname = path.slice(path.lastIndexOf('/') + 1, path.lastIndexOf('.'))
        begin = begin.replace('%name%', name)

    return begin + template.trim() + wrapper.end


run = ->
    parser = argumentum.load(optConfig)
    options = parser.parse()

    if options.helpers
        return compiler.printHelpers(helpers, options['helpers-name'])

    if not options[0]
        return parser.getUsage()

    replaceName = (s) ->

    source = fs.readFileSync(options[0]).toString()

    if options['no-include-helpers']
        template = compiler.compile(source)
    else
        template = compiler.compile(source, helpers, options['helpers-name'])

    return wrap(options.wrap, template, options[0])


console.log(run())
