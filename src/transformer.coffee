_ = require 'underscore'

getWriter = ->
    text: []
    level: 0
    endings: {}

    push: (value) ->
        @text.push value

    result: ->
        @text.join('')

    write: (line, opts={}) ->
        if not line.length
            return
        @push Array(@level + 1).join('  ')
        @push line
        @push '\n'
        if opts.indent
            if typeof opts.indent == 'string'
                @indent(opts.indent)
            else
                @indent()

    indent: (ending) ->
        @endings[@level] = ending
        @level++

    dedent: ->
        if @endings[@level - 1]
            @write(@endings[@level - 1])
            @endings[@level - 1] = null
        @level--


transform = (tokens, options) ->
    options = _.extend({helpers: {}, helpersName: 'helpers', tokenMap: {}},
        options)
    tokenMap = _.extend({}, getDefaultTokenMap(options.helpersName),
        options.tokenMap)

    writer = getWriter()
    writer.write '(ctx) ->', indent: true

    if Object.keys(options.helpers).length
        for line in dumpHelpers(options.helpers, options.helpersName)
            writer.write line

    writer.write '((out) ->', indent: 'out).call(ctx, []).join("")'

    for [type, value] in tokens
        if not value.length
            continue
        fn = tokenMap[type]
        [value, indent] = fn(value, writer)
        writer.write value, indent: indent

    if writer.level != 2
        throw "Fail: end indent is not neutral: #{writer.level - 2}"

    writer.dedent()
    writer.dedent()
    return writer.result()


dumpHelpers = (helpers, helpersName='helpers') ->
    result = ["#{helpersName} = {"]
    for name, value of helpers
        if typeof value == 'string'
            value = JSON.stringify(value)
        else
            value = value.toString()
        result.push "#{name}: `#{value}`"
    result.push '}'
    return result


processCode = (value, writer) ->
    value = value.trim()
    if value.match /^(end|else|when|catch|finally)/
        writer.dedent()
    if value == 'end'
        return ['', false]
    if value.match /(-|=)>/
        # generate a function, so it looks like this:
        # (arg) =>
        #     ((out) =>
        #         out.push "some template with arg"
        #         out
        #     )([]).join("")
        # This can be used as a callback with helpers
        value = value.replace(/(->|=>)$/, '$1 ((out) $1')
        return [value, 'out)([]).join("")']
    else if value[value.length - 1] == ':'
        return [value.slice(0, value.length - 1), true]
    return [value, false]


getDefaultTokenMap = (helpersName) ->
    code: processCode
    literal: (value, writer) ->
        ['out.push ' + JSON.stringify(value), false]
    out: (value, writer) ->
        [value, indent] = processCode(value, writer)
        ["out.push #{value}", indent]
    escape: (value, writer) ->
        [value, indent] = processCode(value, writer)
        ["out.push #{helpersName}.escape #{value}", indent]


exports.getDefaultTokenMap = getDefaultTokenMap
exports.transform = transform
exports.dumpHelpers = dumpHelpers
