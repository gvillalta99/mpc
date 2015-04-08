function! mpc#airline#MpcAirlinePlugin(...)
  if matchstr(&filetype, 'mpdv', -4) == "mpdv"
    let cmd = "mpc status"
    let result = split(system(cmd), "\n")
    if mpc#hasError(result)
      let w:airline_section_a = "[mpc][ERROR]"
      let w:airline_section_b = ""
      let w:airline_section_c = ""
      let w:airline_section_x = get(result, 0, "ERROR")
      let w:airline_section_y = ""
      let w:airline_section_z = ""
    else
      if len(result) == 1
        let track  = "Empty playlist"
        let status = "[stop]"
        let stats  = result[0]
      else
        let track  = get(result, 0, "No track")
        let status = split(result[1], ' ')[0]
        let stats  = result[2]
      endif

      let s:count = len(split(system("mpc playlist"), "\n"))
      let s:settings = split(stats, '   ')

      let w:airline_section_a = '[mpc]' . status
      let w:airline_section_b = s:settings[1]
      let w:airline_section_c = s:settings[2]
      let w:airline_section_x = track
      let w:airline_section_y = " " . s:count . " songs "
    endif
  endif
endfunction
