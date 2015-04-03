function! GetMPCStatusLine()
  let cmd = "mpc status"
  let result = split(system(cmd), "\n")

  let status = len(result) == 3 ? result[2] : result[1]

  let [s:count, s:settings] = 
        \ [len(split(system("mpc playlist"), "\n")),
        \ split(status, '   ')]

  let s:statusline = " "
        \ . s:settings[1] . " --- "
        \ . s:settings[2] . " ---%="
        \ . s:count . " songs "

  return s:statusline
endfunction

setlocal statusline=%!GetMPCStatusLine()
set buftype=nofile
set conceallevel=3
set concealcursor=nvic

command! -buffer PlaySelectedSong call mpc#PlaySong(line('.'))
