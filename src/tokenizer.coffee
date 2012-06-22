BEGIN = '<%'
END = '%>'


tokenize = (source) ->
    tokens = []
    start = 0
    while true
        next = source.indexOf(BEGIN, start)
        if next == -1
            tokens.push(['literal', source.slice(start)])
            break
        if source[next - 1] == '\\'
            continue
        tokens.push(['literal', source.slice(start, next)])
        while true
            end = source.indexOf(END, next)
            if end == -1
                # TODO: calc line/position, maybe print a bit of template
                throw "Fail: logic tag at #{next} not closed"
            if source[end - 1] == '\\'
                continue
            break
        tokens.push(identify(source.slice(next + BEGIN.length, end)))
        start = end + END.length + 1
        if start >= source.length
            break
    return tokens


identify = (s) ->
    switch s[0]
        when '='
            return ['escape', s.slice(1)]
        when '-'
            return ['out', s.slice(1)]
        else
            return ['code', s]


exports.tokenize = tokenize
