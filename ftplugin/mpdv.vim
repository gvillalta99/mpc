" Syntax highlight and buffer configuration
setlocal buftype=nofile conceallevel=3 concealcursor=nvic textwidth=0 nonumber

" Commands for views
command! -buffer AddPathToPlaylist      call mpc#add(getline(line('.')))
command! -buffer DeleteSongFromPlaylist call mpc#del(line('.'))
command! -buffer PlaySelectedSong       call mpc#play(line('.'))
command! -buffer TogglePlayback         call mpc#toggle()
command! -buffer ToggleRandom           call mpc#toggleRandom()
command! -buffer ToggleRepeat           call mpc#toggleRepeat()

" Status bar
if !exists("g:loaded_airline") || !g:loaded_airline
  au FileType *mpdv let statusline=%!mpc#statusbar#MPCStatusbar()
end

" Key mappings {{{

"   Defaults {{{
au FileType mpdv nnoremap <silent><buffer> a :AddPathToPlaylist<cr>
au FileType mpdv nnoremap <silent><buffer> d :DeleteSongFromPlaylist<cr>
au FileType mpdv nnoremap <silent><buffer> e :ToggleRepeat<cr> :AirlineRefresh<cr>
au FileType mpdv nnoremap <silent><buffer> q :bd!<cr>
au FileType mpdv nnoremap <silent><buffer> p :TogglePlayback<cr> :AirlineRefresh<cr>
au FileType mpdv nnoremap <silent><buffer> r :ToggleRandom<cr> :AirlineRefresh<cr>
"   }}}

"   Playlist {{{
if bufname('%') == "playlist.mpdv"
  au FileType mpdv nnoremap <silent><buffer> <Enter> :PlaySelectedSong<cr> :AirlineRefresh<cr>
endif
"   }}}
"   Songlist {{{
if bufname('%') == "songlist.mpdv"
endif
"   }}}
"   Current {{{
if bufname('%') == "songlist.mpdv"
endif
"   }}}
"}}}
