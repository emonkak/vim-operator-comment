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
  let reg_u = [@", getregtype('"')]

  let comment = s:comment_pair()
  let comment_multi_line_p = len(comment) > 1

  let [lnum1, col1] = getpos("'[")[1:2]
  let [lnum2, col2] = getpos("']")[1:2]

  let lines = range(lnum1, lnum2)
  if a:motion_wiseness ==# "line"
    call map(lines, '[v:val, 1]')
  elseif a:motion_wiseness ==# 'block'
    call map(lines, '[v:val, col1]')
  else  " char
    call map(lines, '[v:val, 1]')
    let lines[0] = [lnum1, col1]
  endif

  if comment_multi_line_p
    call cursor(lines[-1][0], col2)
    if a:motion_wiseness ==# 'line'
      normal! $
    endif
    let @" = (col('$') > 1 ? ' ' : '') . comment[1]
    normal! p
    call cursor(lines[0])
    let @" = comment[0] . (col('$') > 1 ? ' ' : '')
    normal! P`[
  else
    for [lnum, col] in lines
      call cursor(lnum, col)
      let @" = comment[0] . (col('$') > 1 ? ' ' : '')
      normal! P`[
    endfor
  endif

  call setreg('"', reg_u[0], reg_u[1])
endfunction




function! operator#comment#uncomment(motion_wiseness)  "{{{2
  let [lnum1, col1] = getpos("'[")[1:2]
  let [lnum2, col2] = getpos("']")[1:2]

  let comment = map(s:comment_pair(), 'escape(v:val, "\\")')
  let comment_multi_line_p = len(comment) > 1

  call cursor(lnum1, col1)

  if comment_multi_line_p
    while line('.') <= lnum2 || col('.') <= col2
      let begin_pos = searchpos('\V' . comment[0], 'Wc', lnum2)
      if begin_pos == [0, 0]
        break
      elseif !s:comment_the_cursor_p()
        if search('.', 'W') == 0
          break
        endif
        continue
      endif

      if searchpair('\V' . comment[0],  '', '\V\s\*' . comment[1],
      \             'W', '', lnum2) == 0
        break
      endif
      normal! v
      let end_pos = searchpos('\V' . comment[1], 'We', lnum2)
      normal! "_d

      call cursor(begin_pos)
      normal! v
      call search('\V' . comment[0] . '\+\s\?', 'We', line('.'))
      normal! "_d
      call cursor(end_pos)
    endwhile
  else
    while line('.') <= lnum2 || col('.') <= col2
      if search('\V' . comment[0], 'Wc', lnum2) == 0
        break
      elseif !s:comment_the_cursor_p()
        if search('.', 'W') == 0
          break
        endif
        continue
      endif

      normal! v
      call search('\V' . comment[0] . '\+\s\?', 'We', line('.'))
      normal! "_d$
    endwhile
  endif

  call cursor(lnum1, col1)
endfunction




" Misc.  "{{{1
function! s:comment_pair()  "{{{2
  return split(&l:commentstring, '\s*%s\s*')
endfunction




function! s:comment_the_cursor_p()  "{{{2
  for id in synstack(line('.'), col('.'))
    if synIDattr(synIDtrans(id), 'name') == 'Comment'
      return 1
    endif
  endfor
  return 0
endfunction




" __END__  "{{{1
" vim: foldmethod=marker
