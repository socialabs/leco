(ctx) ->
  ((out) ->
    if @projects.length
      out.push "\n  "
      for project in @projects
        out.push "\n    <a href=\""
        out.push helpers.escape project.url
        out.push "\">"
        out.push helpers.escape project.name
        out.push "</a>\n    "
        out.push project.description
        out.push "\n  "
      out.push "\n"
    else
      out.push "\n  No projects\n"
    out.push "\n"
    out).call(ctx, []).join("")
