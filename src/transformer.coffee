transform = (tokens, helpersName='helpers') ->
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
    write '(->'
    indent += 1
    write 'out = []'

    for [type, value] in tokens
        switch type
            when 'literal'
                push JSON.stringify(value)
            when 'code'
                value = value.trim()
                if value == 'end'
                    indent -= 1
                else if value[value.length - 1] == ':'
                    value = value.slice(0, value.length - 1)
                    write value
                    indent += 1
                else
                    write value
            when 'out'
                push value
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


exports.transform = transform
