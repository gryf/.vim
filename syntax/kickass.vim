" Vim syntax file
" Language:     Assembler, KickAssembler
" Maintainer:   Roman 'gryf' Dobosz <gryf_esm@o2.pl>
" Last Change:  2012-06-03
" Version:      0.1
"
" To install this file place it in ~/.vim/syntax (*nix/Mac) or in
" $VIMRUNTIME/syntax on Windows and issue command:
"
" :set filetype=kickass
"
" You can also add to your vimrc file autocommand:
"
" autocmd BufRead *.asm set filetype=kickass
"
" From now on, all files with extension 'asm' will have brand new kickass
" syntax.
"
" Enjoy.

syn clear
syn case ignore

syn region asmString start=+"+ end=+"+
syn region asmSString start=+'+ end=+'+ contains=@Spell

syn keyword asm6502Mnemonics    adc and asl bit brk clc cld cli clv cmp cpx cpy
syn keyword asm6502Mnemonics    dec dex dey eor inc inx iny lda ldx ldy lsr nop
syn keyword asm6502Mnemonics    ora pha php pla plp rol ror sbc sec sed sei sta 
syn keyword asm6502Mnemonics    stx sty tax tay tsx txa txs tya

syn keyword asmDtvMnemonics     bra sac sir

syn match asm6502Index  ",\s*[xy]" contains=asm6502Mnemonics,asmDtvMnemonics

syn keyword asm6502Jumps    bcc bcs beq bmi bne bpl bvc bvs jmp jsr rti rts

syn keyword asm6510Illegal  slo rla sre rra sax lax dcp isc anc asr arr sbx
syn keyword asm6510Illegal  dop top jam

syn match asmMacroCall  ":[a-z_][a-z0-9_]*"

syn region asmString    start=+"+ skip=+\\"+ end=+"+ contains=@Spell
syn region asmSString   start=+'+ skip=+\\'+ end=+'+ contains=@Spell

"syn match asmLabel  "[\^\s]\!\?\<[a-z0-9_]*\>[:+-]\?[\s$]" kurwa!!!!!!!!
syn match asmLabel  "^\!\?\<[a-z0-9_]*\>:"
"syn match line "asmLabel2  

syn keyword asmTodo         TODO FIXME XXX TBD NOTE WARNING BUG
syn match   asmLineComment  "\/\/.*" contains=@Spell,asmTodo
syn region  asmComment      start="/\*" end="\*/" contains=@Spell,asmTodo

syn match decNumber     "\<\d\+\>"
syn match hexNumber     "\$\x\+\>"
syn match binNumber     "%[01]\+\>"
syn match asmImmediate  "#\$\x\+\>"
syn match asmImmediate  "#\d\+\>"
syn match asmImmediate  "<\$\x\+\>"
syn match asmImmediate  "<\d\+\>"
syn match asmImmediate  ">\$\x\+\>"
syn match asmImmediate  ">\d\+\>"
syn match asmImmediate  "#<\$\x\+\>"
syn match asmImmediate  "#<\d\+\>"
syn match asmImmediate  "#>\$\x\+\>"
syn match asmImmediate  "#>\d\+\>"

" memory and data directives
syn match kickAssDirectives   "\.\<pc\>"
syn match kickAssDirectives   "\.\<align\>"
syn match kickAssDirectives   "\.\<byte\>"
syn match kickAssDirectives   "\.\<word\>"
syn match kickAssDirectives   "\.\<dword\>"
syn match kickAssDirectives   "\.\<text\>"
syn match kickAssDirectives   "\.\<fill\>"
syn match kickAssDirectives   "\.\<pseudopc\>"

" import directive
syn match kickAssDirectives   "\.\<import\>"

" console output
syn match kickAssDirectives   "\.\<print\>"
syn match kickAssDirectives   "\.\<printnow\>"
syn match kickAssDirectives   "\.\<error\>"

" elements of script language
syn match kickAssDirectives   "\.\<eval\>"

syn match kickAssDirectives   "\.\<var\>"
syn match kickAssDirectives   "\.\<const\>"
syn match kickAssDirectives   "\.\<enum\>"
syn match kickAssDirectives   "\.\<label\>"


syn match kickAssDirectives   ":\<BasicUpstart\>"
syn match kickAssDirectives   "\.\<add\>"
syn match kickAssDirectives   "\.\<assert\>"
syn match kickAssDirectives   "\.\<asserterror\>"
syn match kickAssDirectives   "\.\<define\>"
syn match kickAssDirectives   "\.\<filenamespace\>"
syn match kickAssDirectives   "\.\<for\>"
syn match kickAssDirectives   "\.\<function\>" nextgroup=asmDefName skipwhite
syn match kickAssDirectives   "\.\<if\>"
syn match kickAssDirectives   "\.\<macro\>" nextgroup=asmDefName skipwhite
syn match kickAssDirectives   "\.\<namespace\>"
syn match kickAssDirectives   "\.\<pseudocommand\>"
syn match kickAssDirectives   "\.\<return\>"
syn match kickAssDirectives   "\.\<struct\>"
syn match kickAssDirectives   "\<else\>"
syn match kickAssDirectives   "\<LoadSid\>"
syn match kickAssDirectives   "\<LoadPicture\>"
syn match kickAssDirectives   "\<createFile\>"

syn keyword kickAssColors BLACK WHITE RED CYAN PURPLE GREEN BLUE YELLOW ORANGE
syn keyword kickAssColors BROWN LIGHT_RED DARK_GRAY GRAY LIGHT_GREEN LIGHT_BLUE
syn keyword kickAssColors LIGHT_GRAY

syn keyword kickAssConstants BD_C64FILE BF_BITMAP_SINGLECOLOR BF_KOALA BF_FLI

syn match   asmDefName  "[a-zA-Z_][a-zA-Z0-9_]*" display contained

syn match kickAssFunctions  "\<LoadBinary\>" display contained
syn match kickAssFunctions  "\<LoadPicture\>" display contained
syn match kickAssFunctions  "\<LoadSid\>" display contained
syn match kickAssFunctions  "\<Matrix\>" display contained
syn match kickAssFunctions  "\<RotationMatrix\>" display contained
syn match kickAssFunctions  "\<ScaleMatrix\>" display contained
syn match kickAssFunctions  "\<PerspectiveMatrix\>" display contained
syn match kickAssFunctions  "\<MoveMatrix\>" display contained
syn match kickAssFunctions  "\<writeln\>" display contained

" generic/common methods (same name, different but similar behaviour - 
" depending on context)
syn match kickAssFunctions  "\.\<size\>" display contained
syn match kickAssFunctions  "\.\<get\>" display contained
syn match kickAssFunctions  "\.\<remove\>" display contained

" string methods
syn match kickAssFunctions  "\.\<string\>" display contained

syn match kickAssFunctions  "\.\<charAt\>" display contained
syn match kickAssFunctions  "\.\<substring\>" display contained
syn match kickAssFunctions  "\.\<asBoolean\>" display contained
syn match kickAssFunctions  "\.\<asNumber\>" display contained

syn match kickAssFunctions  "\<toBinaryString\>" display contained
syn match kickAssFunctions  "\<toHexString\>" display contained
syn match kickAssFunctions  "\<toIntString\>" display contained
syn match kickAssFunctions  "\<toOctalString\>" display contained

" Math 
syn keyword kickAssConstants PI E

syn match kickAssFunName    "\<abs\>" contained
syn match kickAssFunName    "\<acos\>" display contained
syn match kickAssFunName    "\<asin\>" display contained
syn match kickAssFunName    "\<atan\>" display contained
syn match kickAssFunName    "\<atan2\>" display contained
syn match kickAssFunName    "\<cbrt\>" display contained
syn match kickAssFunName    "\<ceil\>" display contained
syn match kickAssFunName    "\<cos\>" display contained
syn match kickAssFunName    "\<cosh\>" display contained
syn match kickAssFunName    "\<exp\>" display contained
syn match kickAssFunName    "\<expml\>" display contained
syn match kickAssFunName    "\<floor\>" display contained
syn match kickAssFunName    "\<hypot\>" display contained
syn match kickAssFunName    "\<IEEEremainder\>" display contained
syn match kickAssFunName    "\<log\>" display contained
syn match kickAssFunName    "\<log10\>" display contained
syn match kickAssFunName    "\<log1p\>" display contained
syn match kickAssFunName    "\<max\>" display contained
syn match kickAssFunName    "\<min\>" display contained
syn match kickAssFunName    "\<mod\>" display contained
syn match kickAssFunName    "\<pow\>" display contained
syn match kickAssFunName    "\<random\>" display contained
syn match kickAssFunName    "\<round\>" display contained
syn match kickAssFunName    "\<signum\>" display contained
syn match kickAssFunName    "\<sin\>" display contained
syn match kickAssFunName    "\<sinh\>" display contained
syn match kickAssFunName    "\<sqrt\>" display contained
syn match kickAssFunName    "\<tan\>" display contained
syn match kickAssFunName    "\<tanh\>" display contained
syn match kickAssFunName    "\<toDegrees\>" display contained
syn match kickAssFunName    "\<toRadians\>" display contained

" List
syn match kickAssFunctions  "\<List\>" display contained
" get
syn match kickAssFunctions  "\.\<set\>" display contained
syn match kickAssFunctions  "\.\<add\>" display contained
syn match kickAssFunctions  "\.\<shuffle\>" display contained
syn match kickAssFunctions  "\.\<reverse\>" display contained
syn match kickAssFunctions  "\.\<sort\>" display contained

" Dictionaries (hash tables)
syn keyword kickAssFunctions  Hashtable contained

" get
syn match kickAssFunctions  "\.\<put\>" display contained
syn match kickAssFunctions  "\.\<keys\>" display contained
syn match kickAssFunctions  "\.\<containsKey\>" display contained

" Vector/matrix
syn match kickAssFunctions  /\<Vector\>(/he=e-1
" get
syn match kickAssFunName    "\<getX\>" display contained
syn match kickAssFunName    "\<getY\>" display contained
syn match kickAssFunName    "\<getZ\>" display contained
syn match kickAssFunName    "\<\X\>" display contained

syn region kickAssFunctionsCall  start="[a-z0-9_]\." end="(" contains=kickAssFunName

if !exists("did_kickasm_syntax_inits")
  let did_kickasm_syntax_inits = 1

    hi def link kickAssDirectives   Special
    hi def link asm6510Illegal      Debug
    hi def link asm6502Mnemonics    Type
    hi def link asmDtvMnemonics     Type
    hi def link asm6502Index        None
    hi def link asm6502Jumps        PreCondit
    hi def link asmString           String
    hi def link asmSString          String
    hi def link asmComment          Comment
    hi def link asmLineComment      Comment
    hi def link asmMacroCall        Function
    hi def link asmLabel            Label
    hi def link asmTodo             Todo

    hi def link asmDefName          Function
    hi def link kickAssFunctions    Function
    hi def link kickAssFunName      Function
    hi def link kickAssColors       Constant
    hi def link kickAssConstants    Constant

    hi def link asmImmediate        None
    hi def link hexNumber           None
    hi def link binNumber           None
    hi def link decNumber           None

endif

let b:current_syntax = "kickasm"
