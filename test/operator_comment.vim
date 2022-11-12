silent packadd! vim-operator-user

silent runtime! plugin/operator/comment.vim

function! s:before() abort
  new
  put ='foo'
  put ='bar {'
  put ='  baz'
  put ='  qux'
  put ='}'
  put ='quux'
  normal! ggdd
endfunction

function! s:after() abort
  close!
endfunction

function! s:test_comment_singleline() abort
  call s:before()

  setlocal commentstring=//%s
  map <buffer> _ <Plug>(operator-comment)

  execute 'normal __'
  let expected = [
  \   '// foo',
  \   'bar {',
  \   '  baz',
  \   '  qux',
  \   '}',
  \   'quux',
  \ ]
  call assert_equal(expected, getline(1, line('$')), '')

  execute 'normal 3ggV4gg_'
  let expected = [
  \   '// foo',
  \   'bar {',
  \   '  // baz',
  \   '  // qux',
  \   '}',
  \   'quux',
  \ ]
  call assert_equal(expected, getline(1, line('$')), '')

  call s:after()
endfunction

function! s:test_comment_multiline() abort
  call s:before()

  setlocal commentstring=/*%s*/
  map <buffer> _ <Plug>(operator-comment)

  execute 'normal __'
  let expected = [
  \   '/* foo */',
  \   'bar {',
  \   '  baz',
  \   '  qux',
  \   '}',
  \   'quux',
  \ ]
  call assert_equal(expected, getline(1, line('$')), '')

  execute 'normal 3ggV4gg_'
  let expected = [
  \   '/* foo */',
  \   'bar {',
  \   '  /* baz',
  \   '  qux */',
  \   '}',
  \   'quux',
  \ ]
  call assert_equal(expected, getline(1, line('$')), '')

  call s:after()
endfunction
