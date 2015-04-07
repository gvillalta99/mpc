function! GetMPCStatusLine()
  let cmd = "mpc status"
  let result = split(system(cmd), "\n")

  let status = len(result) == 3 ? result[2] : result[1]

  let s:count = len(split(system("mpc playlist"), "\n"))
  let s:settings = split(status, '   ')

  let s:statusline = " "
        \ . s:settings[1] . " --- "
        \ . s:settings[2] . " ---%="
        \ . s:count . " songs "
  return s:statusline
endfunction

if(g:loaded_airline == 1)
  call airline#add_statusline_func('mpc#airline#MpcAirlinePlugin')
else
  setlocal statusline=%!GetMPCStatusLine()
endif

command! TogglePlayback call mpc#TogglePlayback()
