syntax region mpdArtist matchgroup=mpdArtistSyn 
      \ start=/@ar/ end=/ar@/ contains=mpdArtist concealends
syntax region mpdAlbum matchgroup=mpdAlbumSyn 
      \ start=/@al/ end=/al@/ contains=mpdAlbum concealends
syntax region mpdTitle matchgroup=mpdTitleSyn
      \ start=/@ti/ end=/ti@/ contains=mpdTitle concealends

highlight default mpdArtist ctermbg=234 ctermfg=lightgreen 
highlight default mpdArtist ctermbg=234 ctermfg=lightblue
highlight default mpdArtist ctermbg=234 ctermfg=lightmagenta 
