-- Lua filter: build date field and author field from metadata
-- Shows organization after author on separate line, and handles version/published/updated dates

function Meta(meta)
  local version = meta.version and pandoc.utils.stringify(meta.version) or nil
  local published = meta.published and pandoc.utils.stringify(meta.published) or nil
  local updated = meta.updated and pandoc.utils.stringify(meta.updated) or nil
  local author = meta.author and pandoc.utils.stringify(meta.author) or nil
  local organization = meta.organization and pandoc.utils.stringify(meta.organization) or nil
  local lang = os.getenv("NOTICE_LANG") or "en"
  
  -- Labels based on language
  local labels = {
    en = { version = "Version", published = "Published", updated = "Updated", publishedBy = "Published by" },
    es = { version = "Versión", published = "Publicado", updated = "Actualizado", publishedBy = "Publicado por" }
  }
  local l = labels[lang] or labels["en"]
  
  -- Build author field with organization on separate line using LaTeX
  if author and organization then
    local author_block = author .. "\\\\[0.3em]\\small " .. l.publishedBy .. " " .. organization
    meta.author = pandoc.MetaInlines({pandoc.RawInline("latex", author_block)})
  end
  
  -- Build date field
  if version and published then
    local date_str = l.version .. " " .. version
    
    if updated and updated ~= published then
      date_str = date_str .. " | " .. l.published .. ": " .. published .. " | " .. l.updated .. ": " .. updated
    else
      date_str = date_str .. " | " .. l.published .. ": " .. published
    end
    
    meta.date = pandoc.MetaInlines({pandoc.Str(date_str)})
  end
  
  return meta
end
