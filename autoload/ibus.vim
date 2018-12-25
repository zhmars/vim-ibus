"return '' is for map <expr>

function! ibus#gdbus(cmd)
  return system('
      \ gdbus call --session --dest org.gnome.Shell
      \ --object-path /org/gnome/Shell
      \ --method org.gnome.Shell.Eval ' . a:cmd
      \ )
endfunction

function! ibus#switch(index)
  let l:cmd = printf('"imports.ui.status.keyboard.getInputSourceManager().inputSources[%s].activate()"', a:index)
  call ibus#gdbus(l:cmd)
  return ''
endfunction

function! ibus#inactivate()
  if exists('g:ibus#on_gnome') && g:ibus#on_gnome
    call ibus#switch(g:ibus#layout_config['index'])
  else
    exe "call system('ibus engine " . g:ibus#layout . "')"
  endif
  return ''
endfunction

function! ibus#activate()
  if exists('g:ibus#on_gnome') && g:ibus#on_gnome
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
  if exists('b:was_ibus_on') && b:was_ibus_on
    return ibus#activate()
  else
    return ibus#inactivate()
  endif
endfunction
