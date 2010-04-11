" Vim syntax file
" Language:	OpenUI
" Maintainer:	None
" $Id: opl.vim,v 1.1 2004/06/13 17:34:11 vimboss Exp $

" Open UI Language

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" case is not significant
syn case ignore

" A bunch of useful OPL keywords
syn keyword OPLStatement proc endp abs acos addr adjustalloc alert alloc app
syn keyword OPLStatement append appendsprite asc asin at atan back beep
syn keyword OPLStatement begintrans bookmark break busy byref cache
syn keyword OPLStatement cachehdr cacherec cachetidy call cancel caption
syn keyword OPLStatement changesprite chr$ clearflags close closesprite cls
syn keyword OPLStatement cmd$ committrans compact compress const continue
syn keyword OPLStatement copy cos count create createsprite cursor
syn keyword OPLStatement datetosecs datim$ day dayname$ days daystodate
syn keyword OPLStatement dbuttons dcheckbox dchoice ddate declare dedit
syn keyword OPLStatement deditmulti defaultwin deg delete dfile dfloat
syn keyword OPLStatement dialog diaminit diampos dinit dir$ dlong dow
syn keyword OPLStatement dposition drawsprite dtext dtime dxinput edit else
syn keyword OPLStatement elseif enda endif endv endwh entersend entersend0
syn keyword OPLStatement eof erase err err$ errx$ escape eval exist exp ext
syn keyword OPLStatement external find findfield findlib first fix$ flags
syn keyword OPLStatement flt font freealloc gat gborder gbox gbutton
syn keyword OPLStatement gcircle gclock gclose gcls gcolor gcopy gcreate
syn keyword OPLStatement gcreatebit gdrawobject gellipse gen$ get get$
syn keyword OPLStatement getcmd$ getdoc$ getevent getevent32 geteventa32
syn keyword OPLStatement geteventc getlibh gfill gfont ggmode ggrey gheight
syn keyword OPLStatement gidentity ginfo ginfo32 ginvert giprint glineby
syn keyword OPLStatement glineto gloadbit gloadfont global gmove gorder
syn keyword OPLStatement goriginx goriginy goto gotomark gpatt gpeekline
syn keyword OPLStatement gpoly gprint gprintb gprintclip grank gsavebit
syn keyword OPLStatement gscroll gsetpenwidth gsetwin gstyle gtmode gtwidth
syn keyword OPLStatement gunloadfont gupdate guse gvisible gwidth gx
syn keyword OPLStatement gxborder gxprint gy hex$ hour iabs icon if include
syn keyword OPLStatement input insert int intf intrans key key$ keya keyc
syn keyword OPLStatement killmark kmod last lclose left$ len lenalloc
syn keyword OPLStatement linklib ln loadlib loadm loc local lock log lopen
syn keyword OPLStatement lower$ lprint max mcard mcasc mean menu mid$ min
syn keyword OPLStatement minit minute mkdir modify month month$ mpopup
syn keyword OPLStatement newobj newobjh next notes num$ odbinfo off onerr
syn keyword OPLStatement open openr opx os parse$ path pause peek pi
syn keyword OPLStatement pointerfilter poke pos position possprite print
syn keyword OPLStatement put rad raise randomize realloc recsize rename
syn keyword OPLStatement rept$ return right$ rmdir rnd rollback sci$ screen
syn keyword OPLStatement screeninfo second secstodate send setdoc setflags
syn keyword OPLStatement setname setpath sin space sqr statuswin
syn keyword OPLStatement statwininfo std stop style sum tan testevent trap
syn keyword OPLStatement type uadd unloadlib unloadm until update upper$
syn keyword OPLStatement use usr usr$ usub val var vector week year


syn keyword OPLRepeat while do for
syn keyword OPLConstant NULL TRUE
syn keyword OPLType OuiBooleanT OuiCharT OuiDecimalT OuiFloatT OuiIntegerT
syn keyword OPLType OuiLongT OuiPointerT bool char class

"syn keyword attr
"syn keyword attribute
"syn keyword begin
"syn keyword class
"syn keyword const
"syn keyword constant
"syn keyword declid
"syn keyword div
"syn keyword doobrie
"syn keyword div
"syn keyword not
"syn keyword else
"syn keyword end
"syn keyword enum
"syn keyword export
"syn keyword extern
"syn keyword false
"syn keyword float
"syn keyword func
"syn keyword function
"syn keyword goto
"syn keyword if
"syn keyword in
"syn keyword init
"syn keyword FALSE

"syn keyword initially
"syn keyword inst
"syn keyword instance
"syn keyword int
"syn keyword local
"syn keyword long
"syn keyword message
"syn keyword mnemonic
"syn keyword not
"syn keyword of
"syn keyword on
"syn keyword or
"syn keyword priv
"syn keyword OuiShortT
"syn keyword OuiStringT
"syn keyword OuiZonedT
"syn keyword TRUE
"syn keyword accelerator
"syn keyword action
"syn keyword alias
"syn keyword and
"syn keyword array
"syn keyword private
"syn keyword pub
"syn keyword public
"syn keyword readonly
"syn keyword record
"syn keyword rem
"syn keyword repeat
"syn keyword return
"syn keyword short
"syn keyword slot
"syn keyword slotno
"syn keyword string
"syn keyword to
"syn keyword true
"syn keyword type
"syn keyword until
"syn keyword var
"syn keyword variable
"syn keyword virtual
"syn keyword when
"syn keyword while
"syn keyword zoned

" syn keyword OPLStatement rem


syn match  OPLNumber		"\<\d\+\>"
syn match  OPLNumber		"\<\d\+\.\d*\>"
syn match  OPLNumber		"\.\d\+\>"

syn region  OPLString		start=+"+   end=+"+
syn region  OPLComment		start="REM[\t ]" end="$"
syn match   OPLMathsOperator	"-\|=\|[:<>+\*^/\\]"


" Define the default highliting
hi def link OPLStatement	Statement
hi def link OPLConstant		Constant
hi def link OPLNumber		Number
hi def link OPLString		String
hi def link OPLComment		Comment
hi def link OPLMathsOperator	Conditional
hi def link OPLType		Type
hi def link OPLError		Error

let b:current_syntax = "opl"

" vim: ts=8
