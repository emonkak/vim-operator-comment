function! operator#comment#comment(motion_wiseness) abort
  let tokens = s:parse_comment_string(&l:commentstring)
  if len(tokens) == 1
    call s:comment_out_with_singleline_comment(a:motion_wiseness, tokens[0])
  elseif len(tokens) > 1
    call s:comment_out_with_multiline_comment(a:motion_wiseness,
    \                                         tokens[0],
    \                                         tokens[1])
  endif
endfunction

function! operator#comment#uncomment(motion_wiseness) abort
  let tokens = s:parse_comment_string(&l:commentstring)
  if len(tokens) == 1
    call s:uncomment_singleline_comment(a:motion_wiseness, tokens[0])
  elseif len(tokens) > 1
    call s:uncomment_multiline_comment(a:motion_wiseness, tokens[0], tokens[1])
  endif
endfunction

function! s:comment_out_with_multiline_comment(motion_wiseness, start_comment_marker, end_comment_marker) abort
  let [first_lnum, first_col] = getpos("'[")[1:2]
  let [last_lnum, last_col] = getpos("']")[1:2]

  call cursor(last_lnum, last_col)
  if a:motion_wiseness ==# 'line'
    normal! $
  endif
  let comment = (col('.') < col('$') ? ' ' : '') . a:end_comment_marker
  call s:insert_text_at_cursor('a', comment)

  call cursor(first_lnum, first_col)
  if a:motion_wiseness ==# 'line'
    normal! ^
  endif
  let comment = a:start_comment_marker . (col('.') < col('$') ? ' ' : '')
  call s:insert_text_at_cursor('i', comment)

  call cursor(first_lnum, first_col)
endfunction

function! s:comment_out_with_singleline_comment(motion_wiseness, comment_marker) abort
  let [first_lnum, first_col] = getpos("'[")[1:2]
  let [last_lnum, last_col] = getpos("']")[1:2]

  if a:motion_wiseness ==# 'char'
    let indent_col = virtcol('.')
    call s:create_singleline_comment(a:comment_marker, first_lnum, indent_col)
    let indent_col = min([
    \   s:compute_indent_in_block(first_lnum + 1, last_lnum) + 1,
    \   indent_col,
    \ ])
    for lnum in range(first_lnum + 1, last_lnum)
      call s:create_singleline_comment(a:comment_marker, lnum, indent_col)
    endfor
  elseif a:motion_wiseness ==# 'line'
    let indent_col = s:compute_indent_in_block(first_lnum, last_lnum) + 1
    for lnum in range(first_lnum, last_lnum)
      call s:create_singleline_comment(a:comment_marker, lnum, indent_col)
    endfor
  else  " block
    let indent_col = virtcol('.')
    for lnum in range(first_lnum, last_lnum)
      call s:create_singleline_comment(a:comment_marker, lnum, indent_col)
    endfor
  endif

  call cursor(first_lnum, first_col)
endfunction

function! s:compute_indent_in_block(start_lnum, end_lnum) abort
  let min_indent = -1

  for lnum in range(a:start_lnum, a:end_lnum)
    let indent = indent(lnum)
    if indent == 0 && getline(lnum) == ''
      " Skip empty line
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

function! s:create_singleline_comment(comment_marker, lnum, indent_col) abort
  let col = virtcol2col(0, a:lnum, a:indent_col)
  call cursor(a:lnum, col)
  let insufficient_spaces = a:indent_col - virtcol('$')
  let comment_marker = s:indent_comment_marker(a:comment_marker,
  \                                            insufficient_spaces)
  call s:insert_text_at_cursor('i', comment_marker)
endfunction

function! s:delete_until(pattern, lnum, col) abort
  normal! v
  let position = searchpos(a:pattern, 'Wce', a:lnum)
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

function! s:insert_text_at_cursor(command, text) abort
  let _ = a:text
  silent execute 'normal!' a:command . "\<C-r>=_\<CR>\<Esc>"
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

function! s:uncomment_multiline_comment(motion_wiseness, start_comment_marker, end_comment_marker) abort
  let [first_lnum, first_col, first_off] = getpos("'[")[1:]
  let [last_lnum, last_col, last_off] = getpos("']")[1:]

  let start_pattern = '\V' . escape(a:start_comment_marker, '\\') . ' \?'
  let end_pattern = '\V \?' . escape(a:end_comment_marker, '\\')
  let current_lnum = first_lnum
  let continued = 0

  while current_lnum <= last_lnum
    let flags = continued ? 'W':  'Wc'
    let start_pos = searchpos(start_pattern, flags, last_lnum, 0,
    \                         'exists("g:syntax_on") && !s:in_comment()')
    if start_pos == [0, 0]
      break
    endif
    if !s:contains_region(a:motion_wiseness,
    \                     first_lnum, first_col + first_off,
    \                     last_lnum, last_col + last_off,
    \                     start_pos[0], start_pos[1])
      let continued = 1
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
      let continued = 1
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
    let continued = 0
  endwhile

  call cursor(first_lnum, first_col)
endfunction

function! s:uncomment_singleline_comment(motion_wiseness, comment_marker) abort
  let [first_lnum, first_col, first_off] = getpos("'[")[1:]
  let [last_lnum, last_col, last_off] = getpos("']")[1:]

  let pattern = '\V\%('
  \           . '\^\s\*' . escape(a:comment_marker, '\\') . '\$\|'
  \           . escape(a:comment_marker, '\\') . ' \?'
  \           . '\)'
  let current_lnum = first_lnum
  let continued = 0

  while current_lnum <= last_lnum
    let flags = continued ? 'W':  'Wc'
    let start_pos = searchpos(pattern, flags, last_lnum, 0,
    \                         'exists("g:syntax_on") && !s:in_comment()')
    if start_pos == [0, 0]
      break
    endif
    if !s:contains_region(a:motion_wiseness,
    \                     first_lnum, first_col + first_off,
    \                     last_lnum, last_col + last_off,
    \                     start_pos[0], start_pos[1])
      let continued = 1
      continue
    endif

    call s:delete_until(pattern, start_pos[0], start_pos[1])
    call cursor(start_pos[0] + 1, 1)

    let current_lnum = start_pos[0] + 1
    let continued = 0
  endwhile

  call cursor(first_lnum, first_col)
endfunction
