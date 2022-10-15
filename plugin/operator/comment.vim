if exists('g:loaded_operator_comment')
  finish
endif

call operator#user#define('comment', 'operator#comment#comment')
call operator#user#define('uncomment', 'operator#comment#uncomment')

let g:loaded_operator_comment = 1
