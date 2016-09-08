howl.mode.register
  name: 'nasm'
  aliases: {'asm', 'intel-asm', 'i386', 'x64'}
  extensions: {'s', 'S', 'asm'}
  create: -> bundle_load 'mode'

unload = -> howl.mode.unregister 'nasm'

{
  info:
    author: 'Ryan Gonzalez'
    description: 'An NASM-style Intel assembly bundle'
    license: 'MIT'
  :unload
}
