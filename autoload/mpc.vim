" Data Structures:
"   Song:
"   { position: string,
"     artist:   string,
"     album:    string,
"     title:    string}
"

function! mpc#DisplayPlaylist() abort
  let playlist = mpc#formatPlaylist(mpc#playlist())
  let itemlist = []

  for track in playlist
    let output = track.position
          \ . track.artist
          \ . track.album
          \ . track.title
    call add(itemlist, output)
  endfor

  call mpc#insertListIntoBuffer(itemlist)
endfunction

function! mpc#PlaySong(no) abort
  let song = split(getline(a:no), " ")
  let results = split(system("mpc --format '%title% (%artist%)' play " . song[0]), "\n")
  let message = '[mpc] Now Playing: ' . results[0]

  echomsg message
endfunction

function! mpc#TogglePlayback()
  let cmd = 'mpc toggle'
  let result = split(system(cmd), '\n')[1]

  let message = '[mpc] '
  let message .= split(result, ' ')[0] == '[paused]' ? 'Paused' : 'Playing'
  echomsg message
endfunction

function! mpc#ToggleRandom()
  let cmd = 'mpc random'
  let result = split(split(system(cmd), '\n')[2], '   ')

  let status = len(result) > 3 ? result[2] : result[0]
  let message = status == "random: off" ? '[mpc] Random: off' : '[mpc] Random: on'

  echomsg message
endfunction

function! mpc#ToggleRepeat()
  let cmd = 'mpc repeat'
  let result = split(split(system(cmd), '\n')[2], '   ')

  let status = len(result) > 3 ? result[1] : result[0]
  let message = status == "repeat: off" ? '[mpc] Repeat: off' : '[mpc] Repeat: on'

  echomsg message
endfunction

" mpc#appendListToBuffer(itemlist)
"
" Append all the items in the `itemlist` to curent buffer
function! mpc#appendListToBuffer(itemlist) abort
  for item in a:itemlist
    call append(line('$'), item)
  endfor
endfunction

" mpc#execute(options, command, arguments)
"
" Executes the command line program *mpc*
"
" returns [] if an error has happend
" returns a list of strings that corresponds to the output of the mpc command
function! mpc#execute(options, command, arguments) abort
  let cmd       = "mpc "
  let command   = a:command
  let options   = join(a:options, " ")
  let arguments = join(a:arguments, " ")
  let params = options . " " . command . " " . arguments

  let message = "[mpc] " . params
  let result = split(system(cmd . params), "\n")
  if mpc#hasError(result)
    echomsg message . " -- ERROR"
    echomsg result[0]
    return []
  else
    echomsg message
    return result
  endif
endfunction

" mpc#extractSongFromString(line)
"
" returns a Song data structure from line
function! mpc#extractSongFromString(line) abort
  let item = split(a:line, " @")
  let song = {'position': item[0],
        \     'artist':   item[1],
        \     'album':    item[2],
        \     'title':    item[3]}
  return song
endfunction

" mpc#formatPlaylist(playlist)
"
" returns a formated playlist
function! mpc#formatPlaylist(playlist) abort
  if len(a:playlist) == 0
    return []
  else
    let formated_playlist = []
    for song in a:playlist
      call add(formated_playlist, mpc#formatSong(song))
    endfor
    return formated_playlist
  endif
endfunction

" mpc#formatSong(song)
"
" returns a Song data structure with its fields formated
function! mpc#formatSong(song) abort
  let format_elements = { 'b_position': '',    'a_position': '',
        \                 'b_artist':   '@ar', 'a_artist': 'ar@',
        \                 'b_album':    '@al', 'a_album':  'al@',
        \                 'b_title':    '@ti', 'a_title':  'ti@'}
  let song_fields_length = { 'position':  5,
        \                    'artist':   15,
        \                    'album':    15,
        \                    'title':    30}

  let raw_song = { 'position': mpc#formatStringField(a:song.position, song_fields_length.position),
        \          'artist':   mpc#formatStringField(a:song.artist, song_fields_length.artist),
        \          'album':    mpc#formatStringField(a:song.album, song_fields_length.album),
        \          'title':    mpc#formatStringField(a:song.title, song_fields_length.title) }

  let song = { 'position': format_elements.b_position . raw_song.position . format_elements.a_position,
        \      'artist':   format_elements.b_artist   . raw_song.artist   . format_elements.a_artist,
        \      'album':    format_elements.b_album    . raw_song.album    . format_elements.a_album,
        \      'title':    format_elements.b_title    . raw_song.title    . format_elements.a_title }

  return song
endfunction

" mpc#formatStringField(string, size) 
" mpc#formatStringField(string, size, align)
"
" returns the string formated to fit field size aligned
function! mpc#formatStringField(string, size, ...) abort
  " default value for a:align is 'l'
  if len(a:000) == 1
    let align = a:000[0]
  else 
    let align = "l"
  endif

  if len(a:string) > a:size
    if a:size > 4
      return a:string[0:(a:size-4)] . ".. "
    else
      return a:string[0:(a:size-1)] . " "
    endif
  else
    if align ==? "r"
      let whitespaces = repeat(' ', a:size - len(a:string) - 1)
      return whitespaces . a:string . " "
    else
      let whitespaces = repeat(' ', a:size - len(a:string))
      return a:string . whitespaces
    endif
  endif
endfunction

" mpc#hasError(result)
"
" Verifies if the result was an error
"
" 0 -> false
" 1 -> true
"
" returns true if has a error
" returns false otherwise
function! mpc#hasError(result) abort
  if type(a:result) == type([])
    if len(a:result) == 0
      return 0
    else
      return mpc#hasError(a:result[0])
    endif
  elseif type(a:result) == type(" ")
    return a:result =~# '^error:'
  else
    return 0
  endif
endfunction

" mpc#insertListIntoBuffer(itemlist)
"
" Clear the current buffer and insert all the items into it
function! mpc#insertListIntoBuffer(itemlist) abort
  for item in a:itemlist
    if(item == a:itemlist[0])
      execute "normal! 1GdGI" . item
    else
      call append(line('$'), item)
    endif
  endfor
endfunction

" mpc#playlist()
"
" returns a list of songs that corresponds to the current playlist
function! mpc#playlist() abort
  let options   = ["--format '%position% @%artist% @%album% @%title%'"]
  let command   = "playlist"
  let arguments = []
  let results   = mpc#execute(options, command, arguments)
  let playlist  = []

  if ! mpc#hasError(results)
    for line in results
      call add(playlist, mpc#extractSongFromString(line))
    endfor
  endif

  return playlist
endfunction
