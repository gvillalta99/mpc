" Syntax highlight and buffer configuration
setlocal buftype=nofile conceallevel=3 concealcursor=nvic textwidth=0 nonumber

" Commands for mpdv buffer
command! -buffer PlaySelectedSong call mpc#PlaySong(line('.'))
command! -buffer ToggleRandom call mpc#toggleRandom()
command! -buffer ToggleRepeat call mpc#ToggleRepeat()

" Key mappings
au FileType mpdv nnoremap <silent><buffer> <Enter> :PlaySelectedSong<cr> :AirlineRefresh<cr>
au FileType mpdv nnoremap <silent><buffer> r :ToggleRandom<cr> :AirlineRefresh<cr>
au FileType mpdv nnoremap <silent><buffer> e :ToggleRepeat<cr> :AirlineRefresh<cr>
au FileType mpdv nnoremap <silent><buffer> q :bd!<cr>
au FileType mpdv nnoremap <silent><buffer> p :TogglePlayback<cr> :AirlineRefresh<cr>
