if exists("g:loaded_mpc") && g:loaded_mpc
  finish
else
  let g:loaded_mpc = 1
endif

if exists("g:loaded_airline") && g:loaded_airline
  call airline#add_statusline_func('mpc#airline#MpcAirlinePlugin')
endif
