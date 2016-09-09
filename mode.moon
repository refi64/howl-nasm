{
  api: bundle_load 'api'
  lexer: bundle_load 'lexer'

  comment_syntax: ';'

  indentation:
    more_after: {
      ':%s*$'
      r'\\s*%macro\\s*\\S+\\s*\\d+\\s*$'
      r'\\s*struc\\s*\\S+\\s*$'
    }
    less_after: { r'\\s*%endmacro\\s*$', r'\\s*endstruc\\s*$' }

  auto_pairs:
    '(': ')'
    '[': ']'
    '{': '}'
    "'": "'"
    '"': '"'
    '`': '`'
}
