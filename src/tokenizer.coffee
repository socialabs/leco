_ = require 'underscore'


tokenize = (source, options={}) ->
    options = _.extend {begin: '<%', end: '%>', moreTokenNames: {}}, options
    tokenNames = _.extend {}, defaultTokenNames, options.moreTokenNames
    BEGIN = options.begin
    END = options.end

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
        tokens.push(
            identify(source.slice(next + BEGIN.length, end), tokenNames))
        start = end + END.length
        if start >= source.length
            break
    return tokens


identify = (s, tokenNames) ->
    id = s[0]
    if tokenNames[id]
        return [tokenNames[id], s.slice(1)]
    return ['code', s]


defaultTokenNames =
    '-': 'out'
    '=': 'escape'


exports.defaultTokenNames = defaultTokenNames
exports.tokenize = tokenize
