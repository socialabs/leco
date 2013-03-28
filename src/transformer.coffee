getWriter = (prefixes) ->
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
        if not opts.type
            opts.type = 'code'
        prefix = prefixes[opts.type]
        @push Array(@level + 1).join('  ')
        @push prefix + line
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

transform = (tokens, helpers={}, helpersName='helpers') ->
    writer = getWriter
        code: ''
        literal: 'out.push '
        out: "out.push #{helpersName}.safe "
        escape: "out.push #{helpersName}.escape "


    processCode = (value) ->
        value = value.trim()
        if value.match /^(end|else|when|catch|finally)/
            writer.dedent()
        if value == 'end'
            return ['', false]
        if value.match /(-|=)>/
            value = value.replace(/(->|=>)$/, '((out) $1')
            return [value, 'out)([]).join("")']
        else if value[value.length - 1] == ':'
            return [value.slice(0, value.length - 1), true]
        return [value, false]

    writer.write '(ctx) ->', indent: true

    if Object.keys(helpers).length
        for line in dumpHelpers(helpers, helpersName)
            writer.write line

    writer.write '((out) ->', indent: 'out).call(ctx, []).join("")'

    for [type, value] in tokens
        if not value.length
            continue
        switch type
            when 'literal'
                writer.write JSON.stringify(value), type: type
            when 'code', 'out', 'escape'
                [value, indent] = processCode(value)
                writer.write value, type: type, indent: indent
            else
                throw "Fail: unknown type #{type}"

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


exports.transform = transform
exports.dumpHelpers = dumpHelpers
