function! MpcAirlinePlugin(...)
  if &filetype == 'mpdv'
    let cmd = "mpc status"
    let result = split(system(cmd), "\n")
    let track = result[0]
    let stats =  result[2]
    let status = split(result[1], ' ')[0]

    let s:count = len(split(system("mpc playlist"), "\n"))
    let s:settings = split(stats, '   ')

    let w:airline_section_a = '[mpc]' . status
    let w:airline_section_b = s:settings[1]
    let w:airline_section_c = s:settings[2]
    let w:airline_section_x = track
    let w:airline_section_y = " " . s:count . " songs "
  endif
endfunction

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

set buftype=nofile
set conceallevel=3
set concealcursor=nvic
set textwidth=0

command! -buffer PlaySelectedSong call mpc#PlaySong(line('.'))
command! -buffer ToggleRandom call mpc#ToggleRandom()
command! -buffer ToggleRepeat call mpc#ToggleRepeat()

nnoremap <silent> <buffer>  <Enter>                 :PlaySelectedSong<cr> :AirlineRefresh<cr>
nnoremap <silent> <buffer>  a                       :ToggleRandom<cr> :AirlineRefresh<cr>
nnoremap <silent> <buffer>  e                       :ToggleRepeat<cr> :AirlineRefresh<cr>
nnoremap <silent> <buffer>  q                       :bd!<cr>
nnoremap <silent> <buffer>  p                       :TogglePlayback<cr> :AirlineRefresh<cr>

au BufUnload,BufHidden,BufDelete,BufDelete *.mpdv call airline#remove_statusline_func('MpcAirlinePlugin') | set buftype=

if(g:loaded_airline == 1)
  call airline#add_statusline_func('MpcAirlinePlugin')
else
  setlocal statusline=%!GetMPCStatusLine()
endif
