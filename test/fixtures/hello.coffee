(ctx) ->
  ((out) ->
    out.push "Hello, "
    out.push helpers.escape @name
    out.push ".\nI'M SHOUTING AT YOU, "
    out.push helpers.escape @name.toUpperCase()
    out.push "!\n"
    out).call(ctx, []).join("")
