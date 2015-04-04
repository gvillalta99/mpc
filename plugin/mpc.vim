function! OpenMPC()
  call mpc#ViewPlaylist()
endfunction

function! LargestNumber(no1, no2)
  return a:no1 == a:no2 ? 0 : a:no1 > a:no2 ? 1 : -1
endfunction

function! MpcAirlinePlugin(...)
  if &filetype == 'mpdv'
    let cmd = "mpc status"
    let result = split(system(cmd), "\n")
    if mpc#hasError(result)
      let w:airline_section_a = "[mpc][ERROR]"
      let w:airline_section_b = ""
      let w:airline_section_c = ""
      let w:airline_section_x = result[0]
      let w:airline_section_y = ""
      let w:airline_section_z = ""
    else
      let track  = result[0]
      let status = split(result[1], ' ')[0]
      let stats  =  result[2]

      let s:count = len(split(system("mpc playlist"), "\n"))
      let s:settings = split(stats, '   ')

      let w:airline_section_a = '[mpc]' . status
      let w:airline_section_b = s:settings[1]
      let w:airline_section_c = s:settings[2]
      let w:airline_section_x = track
      let w:airline_section_y = " " . s:count . " songs "
    endif
  endif
endfunction

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
  call airline#add_statusline_func('MpcAirlinePlugin')
else
  setlocal statusline=%!GetMPCStatusLine()
endif

command! TogglePlayback call mpc#TogglePlayback()
command! MpcBrowser call OpenMPC()
