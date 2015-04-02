function! mpc#DisplayPlaylist()
  let cmd = "mpc --format '%position% - %artist% (%album%) - %title%' playlist"
  let playlist = split(system(cmd), '\n')

  for track in playlist
    if(playlist[0] == track)
      execute "normal! 1GdGI" . track
    else
      call append(line('$'), track)
    endif
  endfor
endfunction

function! mpc#GetPlaylist()
  let cmd = "mpc --format '%position% @%artist% @%album% @%title%' playlist"
  let results = split(system(cmd), '\n')
  let playlist = []
  let maxLengths = {'position': [], 'artist': [], 'album': []}

  for item in results
    let song = split(item, " @")
    let [position, artist, album, title] = song

    call add(maxLengths.position, len(position))
    call add(maxLengths.artist, len(artist))
    call add(maxLengths.album, len(album))
  endfor

  call sort(maxLengths.position, "LargestNumber")
  call sort(maxLengths.artist, "LargestNumber")
  call sort(maxLengths.album, "LargestNumber")

  for item in results
    let song = split(item, " @")
    let [position, artist, album, title] = song

    if(maxLengths['position'][-1] + 1 > len(position))
      let position = repeat(' ',
            \ maxLengths.position[-1] - len(position))
            \ . position
    endif

    let position .= ' '
    let artist .= repeat(' ', maxLengths['artist'][-1] + 2 - len(artist))
    let album .= repeat(' ', maxLengths['album'][-1] + 2 - len(album))

    call add(playlist,
          \ {'position': position, 'artist': artist,
          \  'album': album, 'title': title })
  endfor

  return playlist
endfunction

function! mpc#PlaySong(no)
  let song = split(getline(a:no), " ")
  let results = split(system("mpc --format '%title% (%artist%)' play " . song[0]), "\n")
  let message = '[mpc] Now Playing: ' . results[0]

  echomsg message
endfunction
