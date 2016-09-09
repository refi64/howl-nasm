bundle_load = bundle_load
print = print
pairs = pairs
append = table.insert

howl.util.lpeg_lexer ->
  c = capture

  id = (alpha + S'._?')^1 * (alpha + digit + S'_$#@~.?')^0
  ws = c 'whitespace', blank^0
  string_contents = any {
    span "'", "'"
    span '"', '"'
    span '`', '`', '\\'
  }

  identifier = c 'identifier', id

  ul = (c) -> P(c)+P(c\upper!)
  ult = (w) -> [ul c for c in w\gmatch '.']
  uls = (w) -> any ult w
  ulq = (w) -> sequence ult w
  case_word = (words) ->
    any [ulq w for w in *words]

  keyword = c 'keyword', case_word {
    'absolute', 'abs', 'alignb', 'align', 'at', 'bits', 'bnd', 'byte', 'common',
    'cpu', 'default', 'db', 'dd', 'do', 'dq', 'dt', 'dword', 'dw', 'endstruc',
    'equ', 'extern', 'float', 'global', 'iend', 'incbin', 'istruc', 'nobnd',
    'nosplit', 'opsize', 'oword', 'qword', 'rel', 'resb', 'resd', 'reso', 'resq',
    'rest', 'resw', 'resy', 'resz', 'sectalign', 'section', 'segment', 'struc',
    'strict', 'times', 'seq', 'tword', 'use16', 'use32', 'word', 'wrt', 'yword',
    'zword'
  }

  instrs = bundle_load 'instructions'
  instr = c 'function', P (file, pos) ->
    word = file\sub(pos)\match'^%a+'
    if word and instrs[word\lower!]
      pos + #word
    else
      false

  macro = c 'preproc', P'%' * any {
    span '[', ']'
    P'!' * (id + string_contents)^-1
    P'??'
    P'00'
    S'+?'
    R'09'
    P'%' * id
    word {
      'arg', 'assign', 'define', 'defstr', 'deftok', 'depend', 'endmacro',
      'error', 'fatal', 'ifctx', 'ifdef', 'ifempty', 'ifenv', 'ifidni', 'ifidn',
      'ifmacro', 'iftoken', 'if','include', 'line', 'local', 'macro',
      'pathsearch', 'pop', 'push', 'stacksize', 'strcat', 'strlen', 'substr',
      'repl', 'rep', 'rotate', 'xdefine', 'undef', 'unmacro', 'use', 'warning'
    }
  }

  comment = c 'comment', P';' * scan_until eol

  operator = c 'operator', any {
    S'\\:,()[]+*-/%|^&<>~!@'
    case_word {
      '__float8__', '__float16__', '__float32__', '__float64__', '__float80m__',
      '__float80e__', '__float128l__', '__float128h__',
      '__utf16__', '__utf32__'
    }
  }

  special = c 'special', (P'__USE_' * id * '__') + word {
    '__BITS__', '__DATE_NUM__', '__DATE__', '__FILE__', '__FLOAT_DAZ__',
    '__FLOAT_ROUND__', '__FLOAT__', '__Infinity__', '__LINE__',
    '__NASM_VERSION_ID__', '__NASM_VER__', '__NaN__', '__POSIX_TIME__',
    '__PASS__', '__OUTPUT_FORMAT__', '__QNaN__', '__SECT__', '__SNaN__',
    '__TIME_NUM__', '__TIME__', '__UTC_DATE_NUM__', '__UTC_DATE__',
    '__UTC_TIME_NUM__', '__UTC_TIME__'
  }

  gen_regs = ->
    gen =
      ax: true
      cx: true
      dx: true
      bx: true
      sp: false
      bp: false
      si: false
      di: false

    res = {}
    ins = (p) -> append res, P(p)

    for regbase, hl in pairs gen
      ins S'erER'^-1 * ulq regbase
      ins ul(regbase\sub 1, 1) * S'hlHL' if hl

    ins S'sScCdDeEfFgG' * S'sS'
    for i=0,15
      ins S'rR' * P"#{i}" * S'dDwWlL'^-1

    for i=0,7
      ins S'xX'^-1 * S'mM' * S'mM' * P"#{i}"
      ins S'sS' * S'tT' * P"#{i}"

    any res

  reg = c 'special', gen_regs!

  make_num_set = (chr0, chr1, letters, bare_prefix, dec) ->
    chr = if chr1
      chr0 + chr1
    else
      chr0
    usc = chr + P'_'
    digit = chr * usc^0
    seq = digit^1
    oseq = digit^0
    float_suf = P'.' * oseq
    exp_suf = ul'e' * S'+-'^-1 * seq
    p_suf = ul'p' * S'+-'^-1 * oseq

    id_prefix = P'0' * letters
    id_prefix += bare_prefix * #chr if bare_prefix

    run = seq^-1 * float_suf^-1 * (exp_suf + p_suf)^-1

    if dec
      chr * run * letters^-1
    else
      (id_prefix * chr * run) + (chr0 * run * letters)

  number = c 'number', S'+-'^-1 * any {
    make_num_set R'01', nil, uls'by'
    make_num_set R'07', nil, uls'oq'
    make_num_set R'09', R'af' + R'AF', uls'hx', P'$'
    make_num_set R'09', nil, uls'dt', nil, true
  }

  string = c 'string', string_contents

  any {
    comment
    keyword
    instr
    special
    reg
    number
    macro
    operator
    identifier
  }
