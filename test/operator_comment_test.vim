silent packadd! vim-operator-user
silent runtime! plugin/operator/comment.vim

function! s:test_comment_singleline_charwise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let source = [
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
  call s:do_test('vGgc', source, expected, options)
  call s:do_test('Gvgggc', source, expected, options)

  let expected = [
  \   '// if (true) {',
  \   '//   foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '}',
  \ ]
  call s:do_test('v3jgc', source, expected, options)
  call s:do_test('3jv3kgc', source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '// }',
  \ ]
  call s:do_test('jwv3jgc', source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo = 123;',
  \   '  // bar = 456;',
  \   '  // baz = 789;',
  \   '}',
  \ ]
  call s:do_test('j^v2jgc', source, expected, options)
  call s:do_test('j^v2j$gc', source, expected, options)
  call s:do_test('3j$v2k^gc', source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '//   foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jv2jgc', source, expected, options)
  call s:do_test('jv2j$gc', source, expected, options)
  call s:do_test('3j$v2k0gc', source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo // = 123;',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jf=vgc', source, expected, options)
  call s:do_test('jf=v$gc', source, expected, options)
  call s:do_test('j$vF=gc', source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo // = 123;',
  \   '  // bar = 456;',
  \   '  // baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jf=v2jgc', source, expected, options)
  call s:do_test('3jf=v2kgc', source, expected, options)

  let source = [
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
  call s:do_test('jv2jgc', source, expected, options)
  call s:do_test('jv2j$gc', source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo();',
  \   '  //',
  \   '  // baz();',
  \   '}',
  \ ]
  call s:do_test('jwv2jgc', source, expected, options)
  call s:do_test('jwv2j$gc', source, expected, options)
endfunction

function! s:test_comment_singleline_linewise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let source = [
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
  call s:do_test('jgcgc', source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo = 123;',
  \   '  // bar = 456;',
  \   '  // baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jgc2j', source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '// }',
  \ ]
  call s:do_test('2jgc2j', source, expected, options)

  let expected = [
  \   '// if (true) {',
  \   '//   foo = 123;',
  \   '//   bar = 456;',
  \   '  baz = 789;',
  \   '}',
  \ ]
  call s:do_test('gc2j', source, expected, options)

  let expected = [
  \   '// if (true) {',
  \   '//   foo = 123;',
  \   '//   bar = 456;',
  \   '//   baz = 789;',
  \   '// }',
  \ ]
  call s:do_test('gcG', source, expected, options)

  let source = [
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
  call s:do_test('jV2jgc', source, expected, options)
  call s:do_test('jV2j$gc', source, expected, options)

  let source = [
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
  call s:do_test('jV2jgc', source, expected, options)
  call s:do_test('jV2j$gc', source, expected, options)
endfunction

function! s:test_comment_singleline_blockwise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let source = [
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
  call s:do_test("\<C-v>Ggc", source, expected, options)
  call s:do_test("\<C-v>G$gc", source, expected, options)
  call s:do_test("G\<C-v>gg$gc", source, expected, options)
  call s:do_test("G\<C-v>gggc", source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo = 123;',
  \   '  // bar = 456;',
  \   '  // baz = 789;',
  \   '}',
  \ ]
  call s:do_test("j^\<C-v>2jgc", source, expected, options)
  call s:do_test("j^\<C-v>2j$gc", source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo // = 123;',
  \   '  bar // = 456;',
  \   '  baz // = 789;',
  \   '}',
  \ ]
  call s:do_test("jf=\<C-v>2jgc", source, expected, options)
  call s:do_test("jf=\<C-v>2j$gc", source, expected, options)

  let source = [
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
  call s:do_test("j\<C-v>2jgc", source, expected, options)
  call s:do_test("j\<C-v>2j$gc", source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  // foo();',
  \   '  //',
  \   '  // baz();',
  \   '}',
  \ ]
  call s:do_test("jw\<C-v>2jgc", source, expected, options)
  call s:do_test("jw\<C-v>2j$gc", source, expected, options)
endfunction

function! s:test_comment_multiline_charwise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let source = [
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
  call s:do_test('j^v2j$gc', source, expected, options)
  call s:do_test('3j$v2k^gc', source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '/*   foo = 123;',
  \   '  bar = 456;',
  \   '  */ baz = 789;',
  \   '}',
  \ ]
  call s:do_test('jv2jgc', source, expected, options)
  call s:do_test('3jv2kgc', source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo /* = 123;',
  \   '  bar = 456;',
  \   '  baz = */ 789;',
  \   '}',
  \ ]
  call s:do_test('jf=v2jgc', source, expected, options)
  call s:do_test('3jf=v2kgc', source, expected, options)
endfunction

function! s:test_comment_multiline_linewise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let source = [
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
  call s:do_test('jgcgc', source, expected, options)
  call s:do_test('jVgc', source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  /* foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789; */',
  \   '}',
  \ ]
  call s:do_test('jV2jgc', source, expected, options)
  call s:do_test('3jV2kgc', source, expected, options)
endfunction

function! s:test_comment_multiline_blockwise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let source = [
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
  call s:do_test("j^\<C-v>2j$gc", source, expected, options)
  call s:do_test("3j$\<C-v>2k^gc", source, expected, options)

  let expected = [
  \   '/* if (true) {',
  \   '  foo = 123;',
  \   '  bar = 456;',
  \   '  baz = 789;',
  \   '} */',
  \ ]
  call s:do_test("\<C-v>Ggc", source, expected, options)
  call s:do_test("\<C-v>G$gc", source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  /* foo = 123;',
  \   '  bar = 456;',
  \   '  baz = */ 789;',
  \   '}',
  \ ]
  call s:do_test("j^\<C-v>2jf=gc", source, expected, options)
  call s:do_test("3jf=\<C-v>2k^gc", source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  foo /* = 123;',
  \   '  bar = 456;',
  \   '  baz = 789; */',
  \   '}',
  \ ]
  call s:do_test("jf=\<C-v>2j$gc", source, expected, options)
  call s:do_test("3j$\<C-v>2kF=gc", source, expected, options)
endfunction

function! s:test_uncomment_singleline_charwise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let source = [
  \   '// foo',
  \   '// bar',
  \   '// baz',
  \ ]

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('v2jgC', source, expected, options)

  let expected = [
  \   '// foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('wv2jgC', source, expected, options)

  let source = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]

  let expected = [
  \   'foo foo',
  \   'bar bar',
  \   'baz // baz',
  \ ]
  call s:do_test('v2jgC', source, expected, options)

  let expected = [
  \   'foo // foo',
  \   'bar bar',
  \   'baz baz',
  \ ]
  call s:do_test('2wv2jgC', source, expected, options)

  let expected = [
  \   'foo foo',
  \   'bar bar',
  \   'baz baz',
  \ ]
  call s:do_test('wv2jgC', source, expected, options)

  let source = [
  \   '// foo // foo',
  \   '// bar // bar',
  \   '// baz // baz',
  \ ]

  let expected = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test('v2jgC', source, expected, options)

  let expected = [
  \   '// foo foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test('wv2jgC', source, expected, options)
endfunction

function! s:test_uncomment_singleline_linewise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let source = [
  \   '// foo',
  \   '// bar',
  \   '// baz',
  \ ]

  let expected = [
  \   'foo',
  \   '// bar',
  \   '// baz',
  \ ]
  call s:do_test('gCgC', source, expected, options)

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('V2jgC', source, expected, options)

  let source = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]

  let expected = [
  \   'foo foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test('gCgC', source, expected, options)

  let expected = [
  \   'foo foo',
  \   'bar bar',
  \   'baz baz',
  \ ]
  call s:do_test('V2jgC', source, expected, options)

  let source = [
  \   '// foo // foo',
  \   '// bar // bar',
  \   '// baz // baz',
  \ ]

  let expected = [
  \   'foo // foo',
  \   '// bar // bar',
  \   '// baz // baz',
  \ ]
  call s:do_test('gCgC', source, expected, options)

  let expected = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test('V2jgC', source, expected, options)

  let source = [
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
  call s:do_test('jV2jgC', source, expected, options)
endfunction

function! s:test_uncomment_singleline_blockwise() abort
  let options = {
  \   'commentstring': '//%s',
  \   'virtualedit': 'block',
  \ }

  let source = [
  \   '// foo',
  \   '// bar',
  \   '// baz',
  \ ]

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test("\<C-v>2jgC", source, expected, options)

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test("\<C-v>2j$gC", source, expected, options)

  let expected = [
  \   '// foo',
  \   '// bar',
  \   '// baz',
  \ ]
  call s:do_test("w\<C-v>2jgC", source, expected, options)

  let source = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]

  let expected = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test("\<C-v>2jgC", source, expected, options)

  let expected = [
  \   'foo foo',
  \   'bar bar',
  \   'baz baz',
  \ ]
  call s:do_test("\<C-v>2j$gC", source, expected, options)
  call s:do_test("w\<C-v>2jgC", source, expected, options)

  let expected = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test("2w\<C-v>2jgC", source, expected, options)

  let source = [
  \   '// foo // foo',
  \   '// bar // bar',
  \   '// baz // baz',
  \ ]

  let expected = [
  \   'foo // foo',
  \   'bar // bar',
  \   'baz // baz',
  \ ]
  call s:do_test("\<C-v>2jgC", source, expected, options)
  call s:do_test("\<C-v>2j$gC", source, expected, options)

  let expected = [
  \   '// foo // foo',
  \   '// bar // bar',
  \   '// baz // baz',
  \ ]
  call s:do_test("w\<C-v>2jgC", source, expected, options)

  let expected = [
  \   '// foo foo',
  \   '// bar bar',
  \   '// baz baz',
  \ ]
  call s:do_test("2w\<C-v>2jgC", source, expected, options)
endfunction

function! s:test_uncomment_multiline_charwise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let source = [
  \   '/* foo */',
  \   '/* bar */',
  \   '/* baz */',
  \ ]

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('v2j$gC', source, expected, options)
  call s:do_test('2j$v2k0gC', source, expected, options)

  let expected = [
  \   '/* foo */',
  \   'bar',
  \   '/* baz */',
  \ ]
  call s:do_test('wv2jgC', source, expected, options)
  call s:do_test('2jwv2kgC', source, expected, options)

  let expected = [
  \   'foo',
  \   'bar',
  \   '/* baz */',
  \ ]
  call s:do_test('v2jgC', source, expected, options)
  call s:do_test('2jv2kgC', source, expected, options)

  let expected = [
  \   '/* foo */',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('wv2j$gC', source, expected, options)
  call s:do_test('2j$v2kbgC', source, expected, options)

  let source = [
  \   '/* foo */ /* bar */ /* baz */',
  \ ]

  let expected = [
  \   'foo /* bar */ /* baz */',
  \ ]
  call s:do_test('vf/gC', source, expected, options)
  call s:do_test('v2f/gC', source, expected, options)

  let expected = [
  \   'foo bar /* baz */',
  \ ]
  call s:do_test('v3f/gC', source, expected, options)
  call s:do_test('v4f/gC', source, expected, options)

  let expected = [
  \   'foo bar baz',
  \ ]
  call s:do_test('v$gC', source, expected, options)

  let source = [
  \   '/* foo *//* bar *//* baz */',
  \ ]

  let expected = [
  \   'foo/* bar *//* baz */',
  \ ]
  call s:do_test('vf/gC', source, expected, options)
  call s:do_test('v2f/gC', source, expected, options)

  let expected = [
  \   'foobar/* baz */',
  \ ]
  call s:do_test('v3f/gC', source, expected, options)
  call s:do_test('v4f/gC', source, expected, options)

  let expected = [
  \   'foobarbaz',
  \ ]
  call s:do_test('v$gC', source, expected, options)
endfunction

function! s:test_uncomment_multiline_linewise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let source = [
  \   '/* foo */',
  \   '/* bar */',
  \   '/* baz */',
  \ ]

  let expected = [
  \   'foo',
  \   '/* bar */',
  \   '/* baz */',
  \ ]
  call s:do_test('gCgC', source, expected, options)
  call s:do_test('VgC', source, expected, options)

  let expected = [
  \   'foo',
  \   'bar',
  \   'baz',
  \ ]
  call s:do_test('V2jgC', source, expected, options)
  call s:do_test('2jV2kgC', source, expected, options)

  let source = [
  \   '/* foo */ /* bar */ /* baz */',
  \ ]

  let expected = [
  \   'foo bar baz',
  \ ]
  call s:do_test('gCgC', source, expected, options)
  call s:do_test('VgC', source, expected, options)

  let source = [
  \   '/* foo *//* bar *//* baz */',
  \ ]

  let expected = [
  \   'foobarbaz',
  \ ]
  call s:do_test('gCgC', source, expected, options)
  call s:do_test('VgC', source, expected, options)
endfunction

function! s:test_uncomment_multiline_blockwise() abort
  let options = {
  \   'commentstring': '/*%s*/',
  \   'virtualedit': 'block',
  \ }

  let source = [
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
  call s:do_test("\<C-v>G$gC", source, expected, options)
  call s:do_test("G\<C-v>gg$gC", source, expected, options)
  call s:do_test("jw\<C-v>2j$gC", source, expected, options)
  call s:do_test("3j$\<C-v>2k^gC", source, expected, options)

  let expected = [
  \   'if (true) {',
  \   '  /* foo(); */',
  \   '  /* bar(); */',
  \   '  /* baz(); */',
  \   '}',
  \ ]
  call s:do_test("\<C-v>GgC", source, expected, options)
  call s:do_test("G\<C-v>gggC", source, expected, options)
  call s:do_test("jw\<C-v>gC", source, expected, options)
  call s:do_test("j2w\<C-v>2jf;gC", source, expected, options)

  let source = [
  \   '/* foo */ /* bar */ /* baz */',
  \ ]

  let expected = [
  \   'foo /* bar */ /* baz */',
  \ ]
  call s:do_test("\<C-v>f/gC", source, expected, options)
  call s:do_test("\<C-v>2f/gC", source, expected, options)

  let expected = [
  \   'foo bar /* baz */',
  \ ]
  call s:do_test("\<C-v>3f/gC", source, expected, options)
  call s:do_test("\<C-v>4f/gC", source, expected, options)

  let expected = [
  \   'foo bar baz',
  \ ]
  call s:do_test('v$gC', source, expected, options)

  let source = [
  \   '/* foo *//* bar *//* baz */',
  \ ]

  let expected = [
  \   'foo/* bar *//* baz */',
  \ ]
  call s:do_test('vf/gC', source, expected, options)
  call s:do_test('v2f/gC', source, expected, options)

  let expected = [
  \   'foobar/* baz */',
  \ ]
  call s:do_test('v3f/gC', source, expected, options)
  call s:do_test('v4f/gC', source, expected, options)

  let expected = [
  \   'foobarbaz',
  \ ]
  call s:do_test('v$gC', source, expected, options)
endfunction

function! s:do_test(key_strokes, source, expected, options) abort
  new
  for [key, value] in items(a:options)
    execute 'setlocal' (key . '=' . value)
  endfor
  map <buffer> gc <Plug>(operator-comment)
  map <buffer> gC <Plug>(operator-uncomment)
  call setline(1, a:source)
  call feedkeys(a:key_strokes, 'x')
  call assert_equal(a:expected, getline(1, line('$')))
  bdelete!
endfunction
