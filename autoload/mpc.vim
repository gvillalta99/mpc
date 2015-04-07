" Data Structures {{{
"   Song {{{
"   { position: string,
"     artist:   string,
"     album:    string,
"     title:    string }
"     }}}
"     Stats {{{
"     {
"       status: string,
"       position: number,
"       total: number,
"       length: string
"     }
"     }}}
"   }}}
"
" Views {{{
"   Playlist {{{
"   Structure:
"     playlist: [
"       song: [ position, artist, album, title ]
"       song: [ position, artist, album, title ]
"       ...
"     ]
"   }}}
"   Single {{{
"   Example:
"11 @JAY Z/Beyoncé @Magna Carta... Holy Grail @Part II (On the Run)
"[playing] #11/16   2:05/5:34 (37%)
"volume: n/a   repeat: off   random: off   single: off   consume: off
"   Structure:
"     single: [
"       song:     [ position, artist, album, title ]
"       stats:    [status, pos/total, time/length, percent]
"       controls: [ volume, repeat, random, single, consume]
"     ]
"   }}}
" }}}

function! mpc#TogglePlayback() "{{{
  let cmd = 'mpc toggle'
  let result = split(system(cmd), '\n')[1]

  let message = '[mpc] '
  let message .= split(result, ' ')[0] == '[paused]' ? 'Paused' : 'Playing'
  echomsg message
endfunction "}}}

" Plugin views {{{

" mpc#ViewCurrent() {{{
"
" Shows the current song in mpc.mpdv buffer
function! mpc#ViewCurrent() abort
  let current = mpc#current()
  let formated_single = mpc#formatSingle(current)
  let itemlist = mpc#singleToArray(formated_single)

  call mpc#newView(len(itemlist), "current.mpdv")

  call mpc#insertListIntoBuffer(itemlist)
endfunction "}}}

" mpc#ViewPlaylist() {{{
"
" Shows the current playlist in mpc.mpdv buffer
function! mpc#ViewPlaylist() abort
  let playlist = mpc#formatPlaylist(mpc#playlist())
  let itemlist = []

  for song in playlist
    call add(itemlist, join(mpc#songToArray(song), " "))
  endfor

  call mpc#newView(len(itemlist), "playlist.mpdv")

  call mpc#insertListIntoBuffer(itemlist)
endfunction "}}}

" mpc#ViewSonglist() {{{
function! mpc#ViewSonglist() abort
  let playlist = mpc#formatSonglist(mpc#listall())
  let itemlist = []

  let song_order = ['file']

  for song in playlist
    call add(itemlist,
          \ join(mpc#songToArray(song, song_order), " "))
  endfor

  call mpc#newView(len(itemlist), "songlist.mpdv")

  call mpc#insertListIntoBuffer(itemlist)
endfunction "}}}
" }}}

" Functions {{{

"   mpc commands {{{

" mpc#current() {{{
"
" returns the current Single
function! mpc#current() abort
  let options   = ["--format '%position% @%artist% @%album% @%title%'"]
  let command   = "current"
  let arguments = []
  let results   = mpc#execute(options, command, arguments)
  let song = mpc#extractSongFromString(results[0])
  let single = { 'song': song }

  return single
endfunction "}}}

" mpc#execute(options, command, arguments) {{{
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
endfunction "}}}

" mpc#listall {{{
function! mpc#listall() abort
  let options   = ["--format '%file% @%artist% @%album% @%title%'"]
  let command   = "listall"
  let arguments = []
  let results   = mpc#execute(options, command, arguments)
  let songlist  = []

  let custom_fields = [ "file", "artist", "album", "title"]

  for line in results
    call add(songlist, mpc#extractSongFromString(line, custom_fields))
  endfor

  return songlist
endfunction "}}}

" mpc#play(number) {{{
"
" Plays song at position number
function! mpc#play(number) abort
  let options   = ["--format '%position% @%artist% @%album% @%title%'"]
  let command   = "play " . a:number
  let arguments = []
  let results   = mpc#execute(options, command, arguments)
  let song      = mpc#extractSongFromString(get(results, 0))

  let message   = "[mpc] Now playing: " . mpc#songToString(song)

  echomsg string(message)
endfunction
" }}}

" mpc#playlist() {{{
"
" returns a list of songs that corresponds to the current playlist
function! mpc#playlist() abort
  let options   = ["--format '%position% @%artist% @%album% @%title%'"]
  let command   = "playlist"
  let arguments = []
  let results   = mpc#execute(options, command, arguments)
  let playlist  = []

  for line in results
    call add(playlist, mpc#extractSongFromString(line))
  endfor

  return playlist
endfunction "}}}

" mpc#toggleRandom() {{{
"
" Toggle random
function! mpc#toggleRandom()
  let options   = ["--format '%position% @%artist% @%album% @%title%'"]
  let command   = "random"
  let arguments = []
  let results   = mpc#execute(options, command, arguments)
  let result =  split(results[2], '   ')

  let status = len(result) > 3 ? result[2] : result[0]
  let message = status == "random: off" ? '[mpc] Random: off' : '[mpc] Random: on'

  echomsg string(message)
endfunction "}}}

" mpc#toggleRepeat(){{{
function! mpc#toggleRepeat() abort
  let options   = ["--format '%position% @%artist% @%album% @%title%'"]
  let command   = "repeat"
  let arguments = []
  let results   = mpc#execute(options, command, arguments)
  let result =  split(results[2], '   ')

  let status = len(result) > 3 ? result[1] : result[0]
  let message = status == "repeat: off" ? '[mpc] Repeat: off' : '[mpc] Repeat: on'

  echomsg string(message)
endfunction
" }}}
"   }}}

"   Views support functions {{{

" mpc#appendListToBuffer(itemlist) {{{
"
" Append all the items in the `itemlist` to curent buffer
function! mpc#appendListToBuffer(itemlist) abort
  for item in a:itemlist
    call append(line('$'), item)
  endfor
endfunction "}}}

" mpc#insertListIntoBuffer(itemlist) {{{
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
endfunction "}}}

" mpc#newView(size) {{{
" mpc#newView(size, name)
"
" creates a new view with size height
" this view has its size constrained by min_size and max_size
function! mpc#newView(size, ...) abort
  let max_size = winheight(0) * 3 / 5
  let min_size = 5

  if max_size < min_size
    let max_size = min_size
  endif

  let view_size = a:size > max_size ? max_size : a:size

  if a:0
    call mpc#renderMpcView(view_size, a:1)
  else
    call mpc#renderMpcView(view_size)
  endif
endfunction "}}}

" mpc#renderMpcView() {{{
"
" open the buffer mpc.mpdv
"
" mpc#renderMpcView(size)
"
" open the buffer mpc.mpdv with size
function! mpc#renderMpcView(...) abort
  let buffer_name = 'mpc.mpdv'
  if a:0 >= 1
    let size = a:1
  endif

  if a:0 == 2
    let buffer_name = a:2
  endif

  if(bufexists(buffer_name))
    let mpcwin = bufwinnr(buffer_name)

    if(mpcwin == -1)
      execute "sbuffer " . bufnr(buffer_name)
    else
      execute mpcwin . "wincmd w"
    endif
  else
    execute "new " . buffer_name
  endif

  " size argument
  if a:0 >= 1
    execute "resize " . size
  endif
endfunction "}}}
"   }}}

"   Data formatting {{{

" mpc#formatPlaylist(playlist) {{{
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
endfunction "}}}

" mpc#formatSonglist(songlist) {{{
function! mpc#formatSonglist(songlist) abort
  if len(a:songlist) == 0
    return []
  else
    let formated_songlist= []
    let styleHash = { 'file' : { 'size': 0, 'b': '@fi', 'a': 'fi@' } }
    for song in a:songlist
      call add(formated_songlist, mpc#formatSong(song, styleHash))
    endfor
    return formated_songlist
  endif
endfunction "}}}

" mpc#formatSingle(single) {{{
"
" returns a formated single
function! mpc#formatSingle(single) abort
  let song = get(a:single, 'song')
  let stats = get(a:single, 'stats')
  let controls = get(a:single, 'controls')
  let single = {}

  if type(song) == type({})
    let single.song = mpc#formatSong(song)
  endif

  return single
endfunction "}}}

" mpc#formatSong(song) {{{
"
" mpc#formatSong(song, styleHash)
"
" returns a Song data structure with its fields formated
function! mpc#formatSong(song, ...) abort
  let styleHash = {}

  let styleHash['position'] = { 'size': 5, 'b': '', 'a': '' }
  let styleHash['artist'] =   { 'size': 15, 'b': '@ar', 'a': 'ar@' }
  let styleHash['album'] =    { 'size': 15, 'b': '@al', 'a': 'al@' }
  let styleHash['title'] =    { 'size': 30, 'b': '@ti', 'a': 'ti@' }

  if a:0
    let newStyleHash = a:1
    call extend(styleHash, newStyleHash , "force")
  endif

  let raw_song = {}
  for field in keys(styleHash)
    if has_key(a:song, field)
      let raw_song[field] = mpc#formatStringField(a:song[field], get(styleHash[field], 'size', 5))
    endif
  endfor

  let song = {}
  for field in keys(raw_song)
    let song[field] = get(styleHash[field], 'b', '') . raw_song[field] . get(styleHash[field], 'a', '')
  endfor

  return song
endfunction "}}}

" mpc#formatStringField(string, size) {{{
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
    elseif a:size == 0
      return a:string
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
endfunction "}}}
"   }}}

"   Data handling {{{

" mpc#extractSongFromString(line) {{{
"
" mpc#extractSongFromString(line, fields)
"
" returns a Song data structure from line
function! mpc#extractSongFromString(line, ...) abort
  let items = split(a:line, " @")
  let song = {}

  if a:0
    let fields = a:1
    let total  = len(fields)
    let i      = 0

    while i < total
      let song[fields[i]] = get(items, i, 'No ' . fields[i])
      let i = i + 1
    endwhile
  else
    let song = {'position': get(items, 0, '0'),
          \     'artist':   get(items, 1, 'No Artist'),
          \     'album':    get(items, 2, 'No Album'),
          \     'title':    get(items, 3, 'No Title')}
  endif

  return song
endfunction "}}}

" mpc#extractStatsFromString(line) {{{
"
" return a Stats data structure
function! mpc#extractStatsFromString(line) abort
  let [status, part1, part2, percent] = split(a:line, " ")
  status = matchstr(status, "[a-z]\\+")
  let [position, total] = split(part1, "/")
  let [current_time, length] = split(part2, "/")

  return { 'status': status,
        \  'position': position,
        \  'total': total,
        \  'length': length }
endfunction "}}}

" mpc#singleToArray(single) {{{
"
" returns a array with single information
function! mpc#singleToArray(single) abort
  let song = get(a:single, 'song')
  let stats = get(a:single, 'stats')
  let controls = get(a:single, 'controls')
  let array_single = []

  if type(song) == type({})
    call add(array_single, mpc#songToString(song))
  endif

  return array_single
endfunction " }}}

" mpc#songToArray(song) {{{
"
" returns the song values ordered correctly
function! mpc#songToArray(song, ...) abort
  let default_order = ['position', 'artist', 'album', 'title']
  if a:0
    let default_order = a:1
  endif

  let song_array = []
  for field in default_order
    call add(song_array, get(a:song, field, ''))
  endfor
  return song_array
endfunction "}}}

" mpc#songToString(song) {{{
"
" returns the string representation of the song
function! mpc#songToString(song) abort
  let song_array = mpc#songToArray(a:song)
  let song_string = join(song_array, " ")
  return song_string
endfunction "}}}
"   }}}

"   Helpers {{{

" mpc#hasError(result) {{{
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
endfunction "}}}
"   }}}
"}}}
