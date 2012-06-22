transform = (tokens, helpers={}, helpersName='helpers') ->
    coffee = []
    indent = 0

    write = (line) ->
        coffee.push Array(indent + 1).join('  ')
        coffee.push line
        coffee.push '\n'

    push = (line) ->
        write "out.push " + line

    write '(ctx) ->'
    indent += 1

    if Object.keys(helpers).length
        for line in dumpHelpers(helpers, helpersName)
            write line

    write '(->'
    indent += 1
    write 'out = []'

    for [type, value] in tokens
        if not value.length
            continue
        switch type
            when 'literal'
                push JSON.stringify(value)
            when 'code'
                value = value.trim()
                if value.match /^(end|else|when|catch|finally)/
                    indent -= 1
                if value == 'end'
                    continue
                if value.match(/(-|=)>/)
                    write value
                    indent += 1
                else if value[value.length - 1] == ':'
                    value = value.slice(0, value.length - 1)
                    write value
                    indent += 1
                else
                    write value
            when 'out'
                push "#{helpersName}.safe " + value
            when 'escape'
                push "#{helpersName}.escape " + value
            else
                throw "Fail: unknown type #{type}"

    if indent != 2
        throw "Fail: end indent is not neutral: #{indent - 2}"

    write 'out.join("")'
    write ').call(ctx)'
    indent -= 1
    return coffee.join('')


dumpHelpers = (helpers, helpersName) ->
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
