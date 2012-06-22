exports.escape = (value) ->
    if value.templateSafe
        return value
    if not value?
        return ''
    return value.toString()
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/\x22/g, '&quot;')


exports.safe = (value) ->
    if value.templateSafe
        return value
    if not value?
        return ''
    value = value.toString()
    value.templateSafe = true
    return value
