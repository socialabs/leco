(ctx) ->
  ((out) ->
    for item in @items
      out.push "\n  "
      out.push helpers.escape @contentTag "div", class: "item", => ((out) =>
        out.push "\n    "
        out.push helpers.escape @contentTag "span", class: "price", -> ((out) ->
          out.push "$"
          out.push helpers.escape item.price
          out)([]).join("")
        out.push "\n    "
        out.push helpers.escape @contentTag "span", class: "name", -> ((out) ->
          out.push helpers.escape item.name
          out)([]).join("")
        out.push "\n  "
        out)([]).join("")
      out.push "\n"
    out.push "\n"
    out).call(ctx, []).join("")
