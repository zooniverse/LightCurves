# shim for ruby-style t() i18n for templates,
# reading from en.coffee.
# Please replace with real i18n library later.

window.t = (key) ->
  return "N/A"  unless key
  
  # currently does not support ".blah.blah" form right now.    
  keys = key.split(".")
  
  comp = lang.en  
  $(keys).each (_, value) ->
    comp = comp[value] if comp

  if not comp and console
    console.debug "No translation found for key: " + key
    console.log cont
    return "N/A"
    
  comp
