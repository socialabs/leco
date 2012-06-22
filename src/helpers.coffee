exports.escape = (value) ->
    if not value?
        return ''
    if value.templateSafe
        return value
    return value.toString()
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/\x22/g, '&quot;')


exports.safe = (value) ->
    if not value?
        return ''
    if value.templateSafe
        return value
    value = value.toString()
    value.templateSafe = true
    return value
