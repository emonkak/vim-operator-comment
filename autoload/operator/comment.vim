function! operator#comment#comment(motion_wiseness) abort
  let tokens = s:parse_comment_string(&l:commentstring)
  if len(tokens) > 1
    call s:comment_multiline(a:motion_wiseness, tokens[0], tokens[1])
  else
    call s:comment_singleline(a:motion_wiseness, tokens[0])
  endif
endfunction

function! operator#comment#uncomment(motion_wiseness) abort
  let tokens = s:parse_comment_string(&l:commentstring)
  let old_foldenable = &l:foldenable
  setlocal nofoldenable
  try
    if len(tokens) > 1
      call s:uncomment_multiline(a:motion_wiseness, tokens[0], tokens[1])
    else
      call s:uncomment_singleline(a:motion_wiseness, tokens[0])
    endif
  finally
    let &l:foldenable = old_foldenable
  endtry
endfunction

function! s:comment_multiline(motion_wiseness, comment_start, comment_end) abort
  let [first_lnum, first_col] = getpos("'[")[1:2]
  let [last_lnum, last_col] = getpos("']")[1:2]

  call cursor(last_lnum, last_col)
  if a:motion_wiseness ==# 'line'
    normal! $
  endif
  let OUTPUT = (col('$') > 1 ? ' ' : '') . a:comment_end
  silent execute "normal!" "a\<C-r>=OUTPUT\<CR>\<Esc>"

  call cursor(first_lnum, first_col)
  if a:motion_wiseness ==# 'line'
    normal! ^
  endif
  let OUTPUT = a:comment_start . (col('$') > 1 ? ' ' : '')
  silent execute "normal!" "i\<C-r>=OUTPUT\<CR>\<Esc>`[`"

  call cursor(first_lnum, first_col)
endfunction

function! s:comment_singleline(motion_wiseness, comment) abort
  let [first_lnum, first_col] = getpos("'[")[1:2]
  let [last_lnum, last_col] = getpos("']")[1:2]

  let lines = range(first_lnum, last_lnum)
  if a:motion_wiseness ==# 'line'
    call map(lines, '[v:val, 1]')
  elseif a:motion_wiseness ==# 'block'
    call map(lines, '[v:val, first_col]')
  else  " char
    call map(lines, '[v:val, 1]')
    let lines[0][1] = first_col
  endif

  let last_col = 0

  for [lnum, col] in lines
    if a:motion_wiseness ==# 'line'
      call cursor(lnum, 0)
      normal! ^
      if last_col < col('.')
        call cursor(0, last_col)
      endif
    else
      call cursor(lnum, col)
    endif
    let OUTPUT = repeat(&l:expandtab ? ' ' : "\t", last_col - col('$'))
    \          . a:comment
    if col('$') > 1 && col('.') != col('$')
      let OUTPUT .= ' '
      let last_col = col('.')
    endif
    silent execute "normal!" "i\<C-r>=OUTPUT\<CR>\<Esc>`[`"
  endfor

  call cursor(first_lnum, first_col)
endfunction

function! s:uncomment_multiline(motion_wiseness, comment_start, comment_end) abort
  let [first_lnum, first_col] = getpos("'[")[1:2]
  let [last_lnum, last_col] = getpos("']")[1:2]

  while line('.') <= last_lnum || col('.') <= last_col
    let begin_pos = searchpos('\V' . a:comment_start, 'Wc', last_lnum)
    if begin_pos == [0, 0]
      break
    elseif !s:in_comment()
      if search('.', 'W') <= 0
        break
      endif
      continue
    endif

    if searchpair('\V' . a:comment_start, '', '\V\s\*' . a:comment_end,
    \             'W', '', last_lnum) <= 0
      break
    endif

    normal! v
    let end_pos = searchpos('\V' . a:comment_end, 'We', last_lnum)
    normal! "_d
    call cursor(begin_pos)

    if col('.') == col('$') - len(a:comment_start)
      call search('\s\+', 'Wb', line('.'))
    endif
    normal! v
    call search('\V' . a:comment_start . '\+\s\?', 'We', line('.'))
    normal! "_d
    call cursor(end_pos)
  endwhile

  call cursor(first_lnum, first_col)
endfunction

function! s:uncomment_singleline(motion_wiseness, comment) abort
  let [first_lnum, first_col] = getpos("'[")[1:2]
  let [last_lnum, last_col] = getpos("']")[1:2]

  while line('.') <= last_lnum || col('.') <= last_col
    let begin_pos = searchpos('\V' . a:comment, 'Wc', last_lnum)
    if begin_pos == [0, 0]
      break
    elseif !s:in_comment()
      if search('.', 'W') <= 0
        break
      endif
      continue
    endif

    if col('.') == col('$') - len(a:comment)
      call search('\s\+', 'Wb', line('.'))
    endif
    normal! v
    call search('\V' . a:comment . '\+\s\?', 'We', line('.'))
    normal! "_d$
  endwhile

  call cursor(first_lnum, first_col)
endfunction

function! s:parse_comment_string(comment_string) abort
  return map(split(a:comment_string, '\s*%s\s*'),
  \          'escape(v:val, "\\")')
endfunction

function! s:in_comment() abort  "{{{2
  for id in synstack(line('.'), col('.'))
    if synIDattr(synIDtrans(id), 'name') ==# 'Comment'
      return !0
    endif
  endfor
  return 0
endfunction
