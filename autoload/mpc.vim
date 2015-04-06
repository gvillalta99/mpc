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

function! mpc#PlaySong(no) abort "{{{
  let song = split(getline(a:no), " ")
  let results = split(system("mpc --format '%title% (%artist%)' play " . song[0]), "\n")
  let message = '[mpc] Now Playing: ' . results[0]

  echomsg message
endfunction "}}}

function! mpc#TogglePlayback() "{{{
  let cmd = 'mpc toggle'
  let result = split(system(cmd), '\n')[1]

  let message = '[mpc] '
  let message .= split(result, ' ')[0] == '[paused]' ? 'Paused' : 'Playing'
  echomsg message
endfunction "}}}

function! mpc#ToggleRepeat() "{{{
  let cmd = 'mpc repeat'
  let result = split(split(system(cmd), '\n')[2], '   ')

  let status = len(result) > 3 ? result[1] : result[0]
  let message = status == "repeat: off" ? '[mpc] Repeat: off' : '[mpc] Repeat: on'

  echomsg message
endfunction "}}}

" Plugin views {{{

" mpc#ViewPlaylist() {{{
"
" Shows the current playlist in mpc.mpdv buffer
function! mpc#ViewPlaylist() abort
  let playlist = mpc#formatPlaylist(mpc#playlist())
  let itemlist = []

  for song in playlist
    call add(itemlist, join(mpc#songToArray(song), " "))
  endfor

  call mpc#newView(len(itemlist))

  call mpc#insertListIntoBuffer(itemlist)
endfunction "}}}

" mpc#ViewSingle() {{{
"
" Shows the current song in mpc.mpdv buffer
function! mpc#ViewSingle() abort
  let current = mpc#current()
  let formated_single = mpc#formatSingle(current)
  let itemlist = mpc#singleToArray(formated_single)

  call mpc#newView(len(itemlist))

  call mpc#insertListIntoBuffer(itemlist)
endfunction "}}}
" }}}

" Functions {{{

" mpc#appendListToBuffer(itemlist) {{{
"
" Append all the items in the `itemlist` to curent buffer
function! mpc#appendListToBuffer(itemlist) abort
  for item in a:itemlist
    call append(line('$'), item)
  endfor
endfunction "}}}

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

" mpc#extractSongFromString(line) {{{
"
" returns a Song data structure from line
function! mpc#extractSongFromString(line) abort
  let item = split(a:line, " @")
  let song = {'position': item[0],
        \     'artist':   item[1],
        \     'album':    item[2],
        \     'title':    item[3]}
  return song
endfunction "}}}

" mpc#extractStatsFromString(line) {{{
"
" return a Stats data structure
function! mpc#extractStatsFromString(line) abort
  let [status, part1, part2, percent] = split(line, " ")
  status = matchstr(status, "[a-z]\\+")
  let [position, total] = split(part1, "/")
  let [current_time, length] = split(part2, "/")

  return { 'status': status,
        \  'position': position,
        \  'total': total,
        \  'length': length }
endfunction "}}}

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
"
" creates a new view with size height
" this view has its size constrained by min_size and max_size
function! mpc#newView(size) abort
  let max_size = winheight(0) * 3 / 5
  let min_size = 5

  if max_size < min_size
    let max_size = min_size
  endif

  let view_size = a:size > max_size ? max_size : a:size

  call mpc#renderMpcView(view_size)
endfunction "}}}

" mpc#playlist() {{{
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
endfunction "}}}

" mpc#renderMpcView() {{{
"
" open the buffer mpc.mpdv
"
" mpc#renderMpcView(size)
"
" open the buffer mpc.mpdv with size
function! mpc#renderMpcView(...) abort
  if(bufexists('mpc.mpdv'))
    let mpcwin = bufwinnr('mpc.mpdv')

    if(mpcwin == -1)
      execute "sbuffer " . bufnr('mpc.mpdv')
    else
      execute mpcwin . "wincmd w"
    endif
  else
    execute "new mpc.mpdv"
  endif

  " size argument
  if a:0
    execute "resize " . a:1
  endif
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
function! mpc#songToArray(song) abort
  let song_values = [a:song.position, a:song.artist, a:song.album, a:song.title]
  return song_values
endfunction "}}}

" mpc#songToString(song) {{{
"
" returns the string representation of the song
function! mpc#songToString(song) abort
  let song_array = mpc#songToArray(a:song)
  let song_string = join(song_array, " ")
  return song_string
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

  echomsg message
endfunction "}}}

"}}}
