{
  lexer: bundle_load 'lexer'

  comment_syntax: ';'

  indentation:
    more_after: { ':%s*$', r'%macro\\s*\\S+\\s*\\d+\\s*$' }

  auto_pairs:
    '(': ')'
    '[': ']'
    '{': '}'
    "'": "'"
    '"': '"'
}
