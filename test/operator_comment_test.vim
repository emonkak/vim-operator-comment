silent packadd! vim-operator-user
silent runtime! plugin/operator/comment.vim

function s:before() abort
  syntax enable
endfunction

function s:after() abort
  syntax off
endfunction

function! s:test_comment_singleline_charwise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   'if (true) {',
  \   '  foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]

  let expected = [
  \   '// if (true) {',
  \   '//   foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '// }',
  \ ]
  call s:do_test('vGgc', lines, expected, options)
  call s:do_test('Gvgggc', lines, expected, options)

  let expected = [
  \   '// if (true) {',
  \   '//   foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '}',
  \ ]
  call s:do_test('v3jgc', lines, expected, options)
  call s:do_test('3jv3kgc', lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '// }',
  \ ]
  call s:do_test('jwv3jgc', lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo = 123;',
  \   '  // bar = 456;',
  \   '  // baz = 789;',
  \   '}',
  \ ]
  call s:do_test('j^v2jgc', lines, expected, options)
  call s:do_test('j^v2j$gc', lines, expected, options)
  call s:do_test('3j$v2k^gc', lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '//   foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jv2jgc', lines, expected, options)
  call s:do_test('jv2j$gc', lines, expected, options)
  call s:do_test('3j$v2k0gc', lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo // = 123;',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jf=vgc', lines, expected, options)
  call s:do_test('jf=v$gc', lines, expected, options)
  call s:do_test('j$vF=gc', lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo // = 123;',
  \   '  // bar = 456;',
  \   '  // baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jf=v2jgc', lines, expected, options)
  call s:do_test('3jf=v2kgc', lines, expected, options)

  let lines = [
  \  'if (true) {',
  \  '  foo();',
  \  '',
  \  '  baz();',
  \  '}',
  \ ]

  let expected = [
  \   'if (true) {',
  \   '//   foo();',
  \   '//',
  \   '//   baz();',
  \   '}',
  \ ]
  call s:do_test('jv2jgc', lines, expected, options)
  call s:do_test('jv2j$gc', lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo();',
  \   '  //',
  \   '  // baz();',
  \   '}',
  \ ]
  call s:do_test('jwv2jgc', lines, expected, options)
  call s:do_test('jwv2j$gc', lines, expected, options)
endfunction

function! s:test_comment_singleline_linewise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   'if (true) {',
  \   '  foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]

  let expected = [
  \   'if (true) {',
  \   '  // foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jgcgc', lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo = 123;',
  \   '  // bar = 456;',
  \   '  // baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jgc2j', lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '// }',
  \ ]
  call s:do_test('2jgc2j', lines, expected, options)

  let expected = [
  \   '// if (true) {',
  \   '//   foo = 123;',
  \   '//   bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]
  call s:do_test('gc2j', lines, expected, options)

  let expected = [
  \   '// if (true) {',
  \   '//   foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '// }',
  \ ]
  call s:do_test('gcG', lines, expected, options)

  let lines = [
  \   'if (true) {',
  \   '  foo();',
  \   '',
  \   '  baz();',
  \   '}',
  \ ]

  let expected = [
  \   'if (true) {',
  \   '  // foo();',
  \   '  //',
  \   '  // baz();',
  \   '}',
  \ ]
  call s:do_test('jV2jgc', lines, expected, options)
  call s:do_test('jV2j$gc', lines, expected, options)

  let lines = [
  \   'if (true) {',
  \   '  foo();',
  \   '',
  \   '  baz();',
  \   '}',
  \ ]

  let expected = [
  \   'if (true) {',
  \   '  // foo();',
  \   '  //',
  \   '  // baz();',
  \   '}',
  \ ]
  call s:do_test('jV2jgc', lines, expected, options)
  call s:do_test('jV2j$gc', lines, expected, options)
endfunction

function! s:test_comment_singleline_blockwise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   'if (true) {',
  \   '  foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]

  let expected = [
  \   '// if (true) {',
  \   '//   foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '// }',
  \ ]
  call s:do_test("\<C-v>Ggc", lines, expected, options)
  call s:do_test("\<C-v>G$gc", lines, expected, options)
  call s:do_test("G\<C-v>gg$gc", lines, expected, options)
  call s:do_test("G\<C-v>gggc", lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo = 123;',
  \   '  // bar = 456;',
  \   '  // baz = 789;',
  \   '}',
  \ ]
  call s:do_test("j^\<C-v>2jgc", lines, expected, options)
  call s:do_test("j^\<C-v>2j$gc", lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo // = 123;',
  \   '  bar // = 456;',
  \   '  baz // = 789;',
  \   '}',
  \ ]
  call s:do_test("jf=\<C-v>2jgc", lines, expected, options)
  call s:do_test("jf=\<C-v>2j$gc", lines, expected, options)

  let lines = [
  \   'if (true) {',
  \   '  foo();',
  \   '',
  \   '  baz();',
  \   '}',
  \ ]

  let expected = [
  \   'if (true) {',
  \   '//   foo();',
  \   '//',
  \   '//   baz();',
  \   '}',
  \ ]
  call s:do_test("j\<C-v>2jgc", lines, expected, options)
  call s:do_test("j\<C-v>2j$gc", lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo();',
  \   '  //',
  \   '  // baz();',
  \   '}',
  \ ]
  call s:do_test("jw\<C-v>2jgc", lines, expected, options)
  call s:do_test("jw\<C-v>2j$gc", lines, expected, options)
endfunction

function! s:test_comment_multiline_charwise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   'if (true) {',
  \   '  foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]

  let expected = [
  \   'if (true) {',
  \   '  /* foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789; */',
  \   '}',
  \ ]
  call s:do_test('j^v2j$gc', lines, expected, options)
  call s:do_test('3j$v2k^gc', lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '/*   foo = 123;',
  \   '  bar = 456;',
  \   '  */ baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jv2jgc', lines, expected, options)
  call s:do_test('3jv2kgc', lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo /* = 123;',
  \   '  bar = 456;',
  \   '  baz = */ 789;',
  \   '}',
  \ ]
  call s:do_test('jf=v2jgc', lines, expected, options)
  call s:do_test('3jf=v2kgc', lines, expected, options)
endfunction

function! s:test_comment_multiline_linewise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   'if (true) {',
  \   '  foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]

  let expected = [
  \   'if (true) {',
  \   '  /* foo = 123; */',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jgcgc', lines, expected, options)
  call s:do_test('jVgc', lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  /* foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789; */',
  \   '}',
  \ ]
  call s:do_test('jV2jgc', lines, expected, options)
  call s:do_test('3jV2kgc', lines, expected, options)
endfunction

function! s:test_comment_multiline_blockwise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   'if (true) {',
  \   '  foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]

  let expected = [
  \   'if (true) {',
  \   '  /* foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789; */',
  \   '}',
  \ ]
  call s:do_test("j^\<C-v>2j$gc", lines, expected, options)
  call s:do_test("3j$\<C-v>2k^gc", lines, expected, options)

  let expected = [
  \   '/* if (true) {',
  \   '  foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '} */',
  \ ]
  call s:do_test("\<C-v>Ggc", lines, expected, options)
  call s:do_test("\<C-v>G$gc", lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  /* foo = 123;',
  \   '  bar = 456;',
  \   '  baz = */ 789;',
  \   '}',
  \ ]
  call s:do_test("j^\<C-v>2jf=gc", lines, expected, options)
  call s:do_test("3jf=\<C-v>2k^gc", lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo /* = 123;',
  \   '  bar = 456;',
  \   '  baz = 789; */',
  \   '}',
  \ ]
  call s:do_test("jf=\<C-v>2j$gc", lines, expected, options)
  call s:do_test("3j$\<C-v>2kF=gc", lines, expected, options)
endfunction

function! s:test_uncomment_singleline_charwise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   '// foo',
  \   '// bar',
  \   '// baz',
  \ ]

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('v2jgC', lines, expected, options)

  let expected = [
  \   '// foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('wv2jgC', lines, expected, options)

  let lines = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]

  let expected = [
  \   'foo foo',
  \   'bar bar',
  \   'baz // baz',
  \ ]
  call s:do_test('v2jgC', lines, expected, options)

  let expected = [
  \   'foo // foo',
  \   'bar bar',
  \   'baz baz',
  \ ]
  call s:do_test('2wv2jgC', lines, expected, options)

  let expected = [
  \   'foo foo',
  \   'bar bar',
  \   'baz baz',
  \ ]
  call s:do_test('wv2jgC', lines, expected, options)

  let lines = [
  \   '// foo // foo',
  \   '// bar // bar',
  \   '// baz // baz',
  \ ]

  let expected = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test('v2jgC', lines, expected, options)

  let expected = [
  \   '// foo foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test('wv2jgC', lines, expected, options)
endfunction

function! s:test_uncomment_singleline_linewise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   '// foo',
  \   '// bar',
  \   '// baz',
  \ ]

  let expected = [
  \   'foo',
  \   '// bar',
  \   '// baz',
  \ ]
  call s:do_test('gCgC', lines, expected, options)

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('V2jgC', lines, expected, options)

  let lines = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]

  let expected = [
  \   'foo foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test('gCgC', lines, expected, options)

  let expected = [
  \   'foo foo',
  \   'bar bar',
  \   'baz baz',
  \ ]
  call s:do_test('V2jgC', lines, expected, options)

  let lines = [
  \   '// foo // foo',
  \   '// bar // bar',
  \   '// baz // baz',
  \ ]

  let expected = [
  \   'foo // foo',
  \   '// bar // bar',
  \   '// baz // baz',
  \ ]
  call s:do_test('gCgC', lines, expected, options)

  let expected = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test('V2jgC', lines, expected, options)

  let lines = [
  \   'if (true) {',
  \   '  // foo();',
  \   '  //',
  \   '  // bar();',
  \   '}',
  \ ]

  let expected = [
  \   'if (true) {',
  \   '  foo();',
  \   '',
  \   '  bar();',
  \   '}',
  \ ]
  call s:do_test('jV2jgC', lines, expected, options)
endfunction

function! s:test_uncomment_singleline_blockwise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   '// foo',
  \   '// bar',
  \   '// baz',
  \ ]

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test("\<C-v>2jgC", lines, expected, options)

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test("\<C-v>2j$gC", lines, expected, options)

  let expected = [
  \   '// foo',
  \   '// bar',
  \   '// baz',
  \ ]
  call s:do_test("w\<C-v>2jgC", lines, expected, options)

  let lines = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]

  let expected = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test("\<C-v>2jgC", lines, expected, options)

  let expected = [
  \   'foo foo',
  \   'bar bar',
  \   'baz baz',
  \ ]
  call s:do_test("\<C-v>2j$gC", lines, expected, options)
  call s:do_test("w\<C-v>2jgC", lines, expected, options)

  let expected = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test("2w\<C-v>2jgC", lines, expected, options)

  let lines = [
  \   '// foo // foo',
  \   '// bar // bar',
  \   '// baz // baz',
  \ ]

  let expected = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test("\<C-v>2jgC", lines, expected, options)
  call s:do_test("\<C-v>2j$gC", lines, expected, options)

  let expected = [
  \   '// foo // foo',
  \   '// bar // bar',
  \   '// baz // baz',
  \ ]
  call s:do_test("w\<C-v>2jgC", lines, expected, options)

  let expected = [
  \   '// foo foo',
  \   '// bar bar',
  \   '// baz baz',
  \ ]
  call s:do_test("2w\<C-v>2jgC", lines, expected, options)
endfunction

function! s:test_uncomment_multiline_charwise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   '/* foo */',
  \   '/* bar */',
  \   '/* baz */',
  \ ]

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('v2j$gC', lines, expected, options)
  call s:do_test('2j$v2k0gC', lines, expected, options)

  let expected = [
  \   '/* foo */',
  \   'bar',
  \   '/* baz */',
  \ ]
  call s:do_test('wv2jgC', lines, expected, options)
  call s:do_test('2jwv2kgC', lines, expected, options)

  let expected = [
  \   'foo',
  \   'bar',
  \   '/* baz */',
  \ ]
  call s:do_test('v2jgC', lines, expected, options)
  call s:do_test('2jv2kgC', lines, expected, options)

  let expected = [
  \   '/* foo */',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('wv2j$gC', lines, expected, options)
  call s:do_test('2j$v2kbgC', lines, expected, options)

  let lines = [
  \   '/* foo */ /* bar */ /* baz */',
  \ ]

  let expected = [
  \   'foo /* bar */ /* baz */',
  \ ]
  call s:do_test('vf/gC', lines, expected, options)
  call s:do_test('v2f/gC', lines, expected, options)

  let expected = [
  \   'foo bar /* baz */',
  \ ]
  call s:do_test('v3f/gC', lines, expected, options)
  call s:do_test('v4f/gC', lines, expected, options)

  let expected = [
  \   'foo bar baz',
  \ ]
  call s:do_test('v$gC', lines, expected, options)

  let lines = [
  \   '/* foo *//* bar *//* baz */',
  \ ]

  let expected = [
  \   'foo/* bar *//* baz */',
  \ ]
  call s:do_test('vf/gC', lines, expected, options)
  call s:do_test('v2f/gC', lines, expected, options)

  let expected = [
  \   'foobar/* baz */',
  \ ]
  call s:do_test('v3f/gC', lines, expected, options)
  call s:do_test('v4f/gC', lines, expected, options)

  let expected = [
  \   'foobarbaz',
  \ ]
  call s:do_test('v$gC', lines, expected, options)
endfunction

function! s:test_uncomment_multiline_linewise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   '/* foo */',
  \   '/* bar */',
  \   '/* baz */',
  \ ]

  let expected = [
  \   'foo',
  \   '/* bar */',
  \   '/* baz */',
  \ ]
  call s:do_test('gCgC', lines, expected, options)
  call s:do_test('VgC', lines, expected, options)

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('V2jgC', lines, expected, options)
  call s:do_test('2jV2kgC', lines, expected, options)

  let lines = [
  \   '/* foo */ /* bar */ /* baz */',
  \ ]

  let expected = [
  \   'foo bar baz',
  \ ]
  call s:do_test('gCgC', lines, expected, options)
  call s:do_test('VgC', lines, expected, options)

  let lines = [
  \   '/* foo *//* bar *//* baz */',
  \ ]

  let expected = [
  \   'foobarbaz',
  \ ]
  call s:do_test('gCgC', lines, expected, options)
  call s:do_test('VgC', lines, expected, options)
endfunction

function! s:test_uncomment_multiline_blockwise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let lines = [
  \   'if (true) {',
  \   '  /* foo(); */',
  \   '  /* bar(); */',
  \   '  /* baz(); */',
  \   '}',
  \ ]

  let expected = [
  \   'if (true) {',
  \   '  foo();',
  \   '  bar();',
  \   '  baz();',
  \   '}',
  \ ]
  call s:do_test("\<C-v>G$gC", lines, expected, options)
  call s:do_test("G\<C-v>gg$gC", lines, expected, options)
  call s:do_test("jw\<C-v>2j$gC", lines, expected, options)
  call s:do_test("3j$\<C-v>2k^gC", lines, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  /* foo(); */',
  \   '  /* bar(); */',
  \   '  /* baz(); */',
  \   '}',
  \ ]
  call s:do_test("\<C-v>GgC", lines, expected, options)
  call s:do_test("G\<C-v>gggC", lines, expected, options)
  call s:do_test("jw\<C-v>gC", lines, expected, options)
  call s:do_test("j2w\<C-v>2jf;gC", lines, expected, options)

  let lines = [
  \   '/* foo */ /* bar */ /* baz */',
  \ ]

  let expected = [
  \   'foo /* bar */ /* baz */',
  \ ]
  call s:do_test("\<C-v>f/gC", lines, expected, options)
  call s:do_test("\<C-v>2f/gC", lines, expected, options)

  let expected = [
  \   'foo bar /* baz */',
  \ ]
  call s:do_test("\<C-v>3f/gC", lines, expected, options)
  call s:do_test("\<C-v>4f/gC", lines, expected, options)

  let expected = [
  \   'foo bar baz',
  \ ]
  call s:do_test('v$gC', lines, expected, options)

  let lines = [
  \   '/* foo *//* bar *//* baz */',
  \ ]

  let expected = [
  \   'foo/* bar *//* baz */',
  \ ]
  call s:do_test('vf/gC', lines, expected, options)
  call s:do_test('v2f/gC', lines, expected, options)

  let expected = [
  \   'foobar/* baz */',
  \ ]
  call s:do_test('v3f/gC', lines, expected, options)
  call s:do_test('v4f/gC', lines, expected, options)

  let expected = [
  \   'foobarbaz',
  \ ]
  call s:do_test('v$gC', lines, expected, options)
endfunction

function! s:do_test(key_strokes, lines, expected, options) abort
  new
  setfiletype c
  for [key, value] in items(a:options)
    execute 'setlocal' (key . '=' . value)
  endfor
  map <buffer> gc <Plug>(operator-comment)
  map <buffer> gC <Plug>(operator-uncomment)
  call setline(1, a:lines)
  call feedkeys(a:key_strokes, 'x')
  call assert_equal(a:expected, getline(1, line('$')))
  bdelete!
endfunction
