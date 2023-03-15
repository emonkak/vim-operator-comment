# operator-comment

**operator-comment** is a very simple plugin that only provides two operators for comment and uncomment. A comment format is only determined by 'commentstring' option. Plugin specific settings are nothing.

## Requirements

- Vim 8.0 or later
- [operator-user](https://github.com/kana/vim-operator-user) 0.1.0 or later

## Usage

The plugin does not provide any default key mappings. You have to configure key mappings like the following:

```vim
map gc  <Plug>(operator-comment)
map gC  <Plug>(operator-uncomment)
nmap gcc  <Plug>(operator-comment)<Plug>(operator-comment)
nmap gCC  <Plug>(operator-uncomment)<Plug>(operator-uncomment)
```

## Documentation

You can access the [documentation](https://github.com/emonkak/vim-operator-comment/blob/master/doc/operator-comment.txt) from within Vim using `:help operator-comment`.
