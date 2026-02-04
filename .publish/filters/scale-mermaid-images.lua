-- Lua filter: scale mermaid-generated images to 60% width and center them

function Image(el)
  -- Scale all PNG images (mermaid generates PNGs)
  if el.src:match("%.png$") then
    -- Wrap in a centered paragraph
    return pandoc.Para({
      pandoc.RawInline("latex", "\\begin{center}"),
      el,
      pandoc.RawInline("latex", "\\end{center}")
    })
  end
  return el
end
