function! OpenMPC()
  if(bufexists('mpc.mpdv'))
    let mpcwin = bufwinnr('mpc.mpdv')
    if(mpcwin == -1)
      execute "sbuffer " . bufnr('mpc.mpdv')
    else
      execute mpcwin . "wincmd w"
      return
    endif
  else
    execute "new mpc.mpdv"
  endif
  call mpc#DisplayPlaylist()
endfunction

function! LargestNumber(no1, no2)
  return a:no1 == a:no2 ? 0 : a:no1 > a:no2 ? 1 : -1
endfunction

command! TogglePlayback call mpc#TogglePlayback()
command! MpcBrowser call OpenMPC()
