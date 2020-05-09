" operator-comment - Operator for comment and uncomment
" Version: 0.0.0
" Copyright (C) 2011 emonkak <emonkak@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Interface  "{{{1
function! operator#comment#comment(motion_wiseness)  "{{{2
  let comment_tokens = s:comment_tokens()

  if len(comment_tokens) > 1
    call s:do_comment_multiline(a:motion_wiseness, comment_tokens[0], comment_tokens[1])
  else
    call s:do_comment_singleline(a:motion_wiseness, comment_tokens[0])
  endif
endfunction




function! operator#comment#uncomment(motion_wiseness)  "{{{2
  let comment_tokens = s:comment_tokens()
  let original_foldenable = &l:foldenable

  setlocal nofoldenable

  try
    if len(comment_tokens) > 1
      call s:do_uncomment_multiline(a:motion_wiseness, comment_tokens[0], comment_tokens[1])
    else
      call s:do_uncomment_singleline(a:motion_wiseness, comment_tokens[0])
    endif
  finally
    let &l:foldenable = original_foldenable
  endtry
endfunction




" Misc.  "{{{1
function! s:comment_tokens()  "{{{2
  return map(split(&l:commentstring, '\s*%s\s*'),
  \          'escape(v:val, "\\")')
endfunction




function! s:cursor_on_the_comment_p()  "{{{2
  for id in synstack(line('.'), col('.'))
    if synIDattr(synIDtrans(id), 'name') ==# 'Comment'
      return !0
    endif
  endfor
  return 0
endfunction




function! s:do_comment_multiline(motion_wiseness, comment_start, comment_end)  "{{{2
  let reg_0 = [@0, getregtype('0')]

  let [lnum1, col1] = getpos("'[")[1:2]
  let [lnum2, col2] = getpos("']")[1:2]

  call cursor(lnum2, col2)
  if a:motion_wiseness ==# 'line'
    normal! $
  endif
  let @0 = (col('$') > 1 ? ' ' : '') . a:comment_end
  normal! "0p

  call cursor(lnum1, col1)
  if a:motion_wiseness ==# 'line'
    normal! ^
  endif
  let @0 = a:comment_start . (col('$') > 1 ? ' ' : '')
  normal! "0P

  call cursor(lnum1, col1)
  call setreg('0', reg_0[0], reg_0[1])
endfunction




function! s:do_comment_singleline(motion_wiseness, comment)  "{{{2
  let reg_0 = [@0, getregtype('0')]

  let [lnum1, col1] = getpos("'[")[1:2]
  let [lnum2, col2] = getpos("']")[1:2]

  let lines = range(lnum1, lnum2)
  if a:motion_wiseness ==# 'line'
    call map(lines, '[v:val, 1]')
  elseif a:motion_wiseness ==# 'block'
    call map(lines, '[v:val, col1]')
  else  " char
    call map(lines, '[v:val, 1]')
    let lines[0][1] = col1
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
    let @0 = repeat(&l:expandtab ? ' ' : "\t", last_col - col('$'))
    let @0 .= a:comment
    if col('$') > 1 && col('.') != col('$')
      let @0 .= ' '
      let last_col = col('.')
    endif
    normal! "0P
  endfor

  call cursor(lnum1, col1)
  call setreg('0', reg_0[0], reg_0[1])
endfunction




function! s:do_uncomment_multiline(motion_wiseness, comment_start, comment_end)  "{{{2
  let [lnum1, col1] = getpos("'[")[1:2]
  let [lnum2, col2] = getpos("']")[1:2]

  while line('.') <= lnum2 || col('.') <= col2
    let begin_pos = searchpos('\V' . a:comment_start, 'Wc', lnum2)
    if begin_pos == [0, 0]
      break
    elseif !s:cursor_on_the_comment_p()
      if search('.', 'W') <= 0
        break
      endif
      continue
    endif

    if searchpair('\V' . a:comment_start, '', '\V\s\*' . a:comment_end,
    \             'W', '', lnum2) <= 0
      break
    endif

    normal! v
    let end_pos = searchpos('\V' . a:comment_end, 'We', lnum2)
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

  call cursor(lnum1, col1)
endfunction




function! s:do_uncomment_singleline(motion_wiseness, comment)  "{{{2
  let [lnum1, col1] = getpos("'[")[1:2]
  let [lnum2, col2] = getpos("']")[1:2]

  while line('.') <= lnum2 || col('.') <= col2
    let begin_pos = searchpos('\V' . a:comment, 'Wc', lnum2)
    if begin_pos == [0, 0]
      break
    elseif !s:cursor_on_the_comment_p()
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

  call cursor(lnum1, col1)
endfunction




" __END__  "{{{1
" vim: foldmethod=marker
