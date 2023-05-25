function! operator#comment#comment(motion_wiseness) abort
  let original_foldenable = &l:foldenable
  try
    setlocal nofoldenable
    let tokens = s:parse_comment_string(&l:commentstring)
    if len(tokens) == 1
      call s:comment_out_with_singleline_comment(a:motion_wiseness, tokens[0])
    elseif len(tokens) > 1
      call s:comment_out_with_multiline_comment(a:motion_wiseness,
      \                                         tokens[0],
      \                                         tokens[1])
    endif
  finally
    let &l:foldenable = original_foldenable
  endtry
endfunction

function! operator#comment#uncomment(motion_wiseness) abort
  let original_foldenable = &l:foldenable
  try
    setlocal nofoldenable
    let tokens = s:parse_comment_string(&l:commentstring)
    if len(tokens) == 1
      call s:uncomment_singleline_comment(a:motion_wiseness, tokens[0])
    elseif len(tokens) > 1
      call s:uncomment_multiline_comment(a:motion_wiseness, tokens[0], tokens[1])
    endif
  finally
    let &l:foldenable = original_foldenable
  endtry
endfunction

function! s:comment_out_with_multiline_comment(motion_wiseness, start_comment_marker, end_comment_marker) abort
  let [first_lnum, first_col] = getpos("'[")[1:2]
  let [last_lnum, last_col] = getpos("']")[1:2]

  call cursor(last_lnum, last_col)
  if a:motion_wiseness ==# 'line'
    normal! $
  endif
  let comment = (col('.') < col('$') ? ' ' : '') . a:end_comment_marker
  call s:put_text('p', comment)

  call cursor(first_lnum, first_col)
  if a:motion_wiseness ==# 'line'
    normal! ^
  endif
  let comment = a:start_comment_marker . (col('.') < col('$') ? ' ' : '')
  call s:put_text('P', comment)

  call cursor(first_lnum, first_col)
endfunction

function! s:comment_out_with_singleline_comment(motion_wiseness, comment_marker) abort
  let [first_lnum, first_col] = getpos("'[")[1:2]
  let [last_lnum, last_col] = getpos("']")[1:2]

  if a:motion_wiseness ==# 'char'
    let indent_col = virtcol('.')
    call s:create_indented_comment(a:comment_marker, first_lnum, indent_col)
    let indent_col = min([
    \   s:compute_indent_in_block(first_lnum + 1, last_lnum) + 1,
    \   indent_col,
    \ ])
    for lnum in range(first_lnum + 1, last_lnum)
      call s:create_indented_comment(a:comment_marker, lnum, indent_col)
    endfor
  elseif a:motion_wiseness ==# 'line'
    let indent_col = s:compute_indent_in_block(first_lnum, last_lnum) + 1
    for lnum in range(first_lnum, last_lnum)
      call s:create_indented_comment(a:comment_marker, lnum, indent_col)
    endfor
  else  " block
    let indent_col = virtcol('.')
    for lnum in range(first_lnum, last_lnum)
      call s:create_indented_comment(a:comment_marker, lnum, indent_col)
    endfor
  endif

  call cursor(first_lnum, first_col)
endfunction

function! s:compute_indent_in_block(start_lnum, end_lnum) abort
  let min_indent = -1

  for lnum in range(a:start_lnum, a:end_lnum)
    let indent = indent(lnum)
    if indent == 0 && getline(lnum) == ''
      " Skip an empty line.
      continue
    endif
    if min_indent == -1 || min_indent > indent
      let min_indent = indent
    endif
  endfor

  return min_indent
endfunction

function! s:contains_region(motion_wiseness, start_lnum, start_col, end_lnum, end_col, lnum, col) abort
  if a:motion_wiseness ==# 'line'
    return a:lnum >= a:start_lnum && a:lnum <= a:end_lnum
  elseif a:motion_wiseness ==# 'char'
    return a:lnum >= a:start_lnum && a:lnum <= a:end_lnum
    \      && (a:lnum != a:start_lnum || a:col >= a:start_col)
    \      && (a:lnum != a:end_lnum || a:col <= a:end_col)
  else " block
    return a:lnum >= a:start_lnum && a:lnum <= a:end_lnum
    \      && (a:col >= a:start_col && a:col <= a:end_col)
  endif
endfunction

function! s:create_indented_comment(comment_marker, lnum, indent_col) abort
  call s:set_virtual_cursor(a:lnum, a:indent_col)
  let insufficient_spaces = a:indent_col - virtcol('$')
  let comment_marker = s:indent_comment_marker(a:comment_marker,
  \                                            insufficient_spaces)
  call s:put_text('P', comment_marker)
endfunction

function! s:delete_until(pattern, lnum, col) abort
  normal! v
  let position = searchpos(a:pattern, 'Wce', a:lnum)
  if col('.') == col('$') - 1
    " Remove trailing spaces.
    normal! o
    call search('\s*\%#', 'Wb', a:lnum)
  endif
  normal! "_d
  return (position[1] - a:col) + 1
endfunction

function! s:in_comment() abort
  for id in synstack(line('.'), col('.'))
    if synIDattr(synIDtrans(id), 'name') ==# 'Comment'
      return 1
    endif
  endfor
  return 0
endfunction

function! s:indent_comment_marker(comment_marker, insufficient_spaces) abort
  if a:insufficient_spaces > 0
    return s:make_indent_characters(a:insufficient_spaces) . a:comment_marker
  elseif a:insufficient_spaces < 0
    return a:comment_marker . ' '
  else
    return a:comment_marker
  endif
endfunction

function! s:make_indent_characters(request_spaces) abort
  if &l:expandtab
    let spaces = repeat(' ', a:request_spaces)
    return spaces
  else
    let tabs = repeat("\t", a:request_spaces / &l:tabstop)
    let spaces = repeat(' ', a:request_spaces % &l:tabstop)
    return tabs . spaces
  endif
endfunction

function! s:parse_comment_string(comment_string) abort
  return split(a:comment_string, '\s*%s\s*')
endfunction

function! s:put_text(command, text) abort
  let reg_value = @"
  let reg_type = getregtype('"')
  call setreg('"', a:text, 'v')
  try
    execute 'normal!' ('""' . a:command)
  finally
    call setreg('"', reg_value, reg_type)
  endtry
endfunction

function! s:set_virtual_cursor(lnum, virtual_col) abort
  if exists('*virtcol2col')
    let col = virtcol2col(0, a:lnum, a:virtual_col)
    call cursor(a:lnum, col)
  else
    call cursor(a:lnum, a:virtual_col)
    while a:virtual_col < virtcol('.')
      normal! h
    endwhile
  endif
endfunction

function! s:uncomment_multiline_comment(motion_wiseness, start_comment_marker, end_comment_marker) abort
  let [first_lnum, first_col, first_off] = getpos("'[")[1:]
  let [last_lnum, last_col, last_off] = getpos("']")[1:]

  let start_pattern = '\V' . escape(a:start_comment_marker, '\\') . ' \?'
  let end_pattern = '\V \?' . escape(a:end_comment_marker, '\\')
  let current_lnum = first_lnum
  let flags = 'Wc'

  while current_lnum <= last_lnum
    let start_pos = searchpos(start_pattern, flags, last_lnum, 0)
    if start_pos == [0, 0]
      break
    endif
    if (exists('g:syntax_on') && !s:in_comment())
    \  || !s:contains_region(a:motion_wiseness,
    \                        first_lnum, first_col + first_off,
    \                        last_lnum, last_col + last_off,
    \                        start_pos[0], start_pos[1])
      let flags = 'W'
      continue
    endif

    let end_pos = searchpairpos(start_pattern, '', end_pattern, 'W',
    \                           'exists("g:syntax_on") && !s:in_comment()',
    \                           last_lnum)
    if end_pos == [0, 0]
      break
    endif
    if !s:contains_region(a:motion_wiseness,
    \                     first_lnum, first_col + first_off,
    \                     last_lnum, last_col + last_off,
    \                     end_pos[0], end_pos[1])
      let flags = 'W'
      continue
    endif

    let deleted_columns = s:delete_until(end_pattern, end_pos[0], end_pos[1])
    if end_pos[0] == last_lnum
      let last_col -= deleted_columns
    endif
    call cursor(start_pos)

    let deleted_columns = s:delete_until(start_pattern,
    \                                    start_pos[0],
    \                                    start_pos[1])
    if start_pos[0] == last_lnum
      let last_col -= deleted_columns
    endif
    if start_pos[0] == end_pos[0]
      let end_pos[1] -= deleted_columns
    endif
    call cursor(end_pos)

    let current_lnum = end_pos[0]
    let flags = 'Wc'
  endwhile

  call cursor(first_lnum, first_col)
endfunction

function! s:uncomment_singleline_comment(motion_wiseness, comment_marker) abort
  let [first_lnum, first_col, first_off] = getpos("'[")[1:]
  let [last_lnum, last_col, last_off] = getpos("']")[1:]

  let pattern = '\V' . escape(a:comment_marker, '\\') . ' \?'
  let current_lnum = first_lnum
  let positions_to_delete = []
  let flags = 'Wc'

  while current_lnum <= last_lnum
    let pos = searchpos(pattern, flags, last_lnum, 0)
    if pos == [0, 0]
      break
    endif
    if (exists('g:syntax_on') && !s:in_comment())
    \  || !s:contains_region(a:motion_wiseness,
    \                        first_lnum, first_col + first_off,
    \                        last_lnum, last_col + last_off,
    \                        pos[0], pos[1])
      let flags = 'W'
      continue
    endif

    call add(positions_to_delete, pos)

    " Move the cursor to the next line.
    call cursor(pos[0] + 1, 1)

    let current_lnum = pos[0] + 1
    let flags = 'Wc'
  endwhile

  for pos in positions_to_delete
    call cursor(pos)
    call s:delete_until(pattern, pos[0], pos[1])
  endfor

  call cursor(first_lnum, first_col)
endfunction
