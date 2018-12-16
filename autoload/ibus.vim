"return '' is for map <expr>

function! ibus#gdbus(cmd)
  return system('
      \ gdbus call --session --dest org.gnome.Shell
      \ --object-path /org/gnome/Shell
      \ --method org.gnome.Shell.Eval ' . a:cmd
      \ )
endfunction

function! ibus#index()
  let l:cmd = '"imports.ui.status.keyboard.getInputSourceManager().inputSources"'
  let l:input_sources = ibus#gdbus(l:cmd)
  let l:input_sources = json_decode(split(l:input_sources, "'")[1])

  for i in keys(l:input_sources)
    if l:input_sources[i]['type'] == g:ibus#layout_config['type']
      \ && l:input_sources[i]['id'] == g:ibus#layout_config['id']
      let g:ibus#layout_config['index'] = l:input_sources[i]['index']

    elseif l:input_sources[i]['type'] == g:ibus#engine_config['type']
      \ && l:input_sources[i]['id'] == g:ibus#engine_config['id']
      let g:ibus#engine_config['index'] = l:input_sources[i]['index']
    endif
  endfor
endfunction

function! ibus#switch(index)
  let l:cmd = printf('"imports.ui.status.keyboard.getInputSourceManager().inputSources[%s].activate()"', a:index)
  call ibus#gdbus(l:cmd)
  return ''
endfunction

function! ibus#inactivate()
  if g:ibus#in_gnome3
    call ibus#switch(g:ibus#layout_config['index'])
  else
    exe "call system('ibus engine " . g:ibus#layout . "')"
  endif
  return ''
endfunction

function! ibus#activate()
  if g:ibus#in_gnome3
    call ibus#switch(g:ibus#engine_config['index'])
  else
    exe "call system('ibus engine " . g:ibus#engine . "')"
  endif
  return ''
endfunction

function! ibus#toggle()
  if ibus#is_on()
    return ibus#inactivate()
  else
    return ibus#activate()
  endif
endfunction

function! ibus#is_on()
  return system('ibus engine') =~ g:ibus#engine ? v:true : v:false
endfunction

function! ibus#inactivate_with_state()
  let b:was_ibus_on = ibus#is_on()
  return ibus#inactivate()
endfunction

function! ibus#restore_state()
  if b:was_ibus_on
    return ibus#activate()
  else
    return ibus#inactivate()
  endif
endfunction
