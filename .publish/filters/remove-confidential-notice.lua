-- Lua filter: remove CONFIDENTIAL/CONFIDENCIAL blockquote from body
-- The notice will be injected via LaTeX include-before-body instead
-- This allows proper page break control

function BlockQuote(el)
  local text = pandoc.utils.stringify(el)
  if text:match("CONFIDENTIAL") or text:match("CONFIDENCIAL") then
    return {}  -- Remove the blockquote
  end
  return el
end
