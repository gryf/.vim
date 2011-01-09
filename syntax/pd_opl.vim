" Vim syntax file
" Language:	OpenUI/OPL
" Maintainer:	Roman 'gryf' Dobosz
" $Id: opl.vim,v 1.0 2011/01/09 17:34:11 vimboss Exp $

" Open UI Language
if exists("b:current_syntax")
  finish
endif

syn region  OPLString		start=+"+ end=+"+ contains=@Spell
syn region  OPLSString		start=+'+ end=+'+ contains=@Spell
syn match   OPLNumber		"\<\d\+\>" display
syn match   OPLFloat		"\<\d\+\.\d\+\>"
"syn match  OPLFloat		"\.\d\+\>"

syn keyword OPLCommentTodo	TODO FIXME XXX TBD
syn match   OPLLineComment	"\/\/.*" contains=@Spell,OPLCommentTodo
syn region  OPLComment		start="/\*"  end="\*/" contains=@Spell,OPLCommentTodo

syn keyword OPLConditional	if else when goto
syn keyword OPLRepeat		for while
syn keyword OPLConstant		TRUE FALSE true false NULL

syn keyword OPLType	OuiBooleanT OuiCharT OuiDecimalT OuiFloatT OuiIntegerT
syn keyword OPLType	OuiLongT OuiPointerT OuiShortT OuiStringT
syn keyword OPLType	array bool char const constant enum float inst
syn keyword OPLType	int long message record short string

syn keyword OPLStatement	class of return const var module on message
syn keyword OPLStatement	initially instance private public type var
syn keyword OPLStatement	variable when while 

syn keyword OPLOperator		and in not div

syn keyword OPLStatement	class function nextgroup=OPLFunction skipwhite
syn match   OPLFunction		"[a-zA-Z_][a-zA-Z0-9_]*" display contained
syn match   OPLSpecial		"::\~\?\zs\h\w*\ze([^)]*\()\s*\(const\)\?\)\?"
syn match   OPLKeyword		"\^\w*\~\?"

" Highlight Class and Function names
syn match    OPLCustomParen	"(" "contains=Paren,cCppParen
syn match    OPLCustomFunction	"\w\+\s*(" contains=OPLCustomParen
"syn match    OPLCustomScope	"::"
"syn match    OPLCustomClass	"\w\+\s*::" contains=OPLCustomScope

" Folding
syn region OPLFold start="{" end="}" transparent fold
"syn sync fromstart
setlocal foldmethod=syntax
setlocal nofoldenable

" Define the default highliting
hi def link OPLComment		Comment
hi def link OPLLineComment	Comment
hi def link OPLNumber		Number
hi def link OPLFloat		Float
hi def link OPLFunction		Function
hi def link OPLConstant		Constant
hi def link OPLStatement	Statement
hi def link OPLString		String
hi def link OPLSString		String
hi def link OPLType		Type
hi def link OPLConditional	Conditional
hi def link OPLCommentTodo	Todo
hi def link OPLSpecial		Special
hi def link OPLKeyword		Keyword
hi def link OPLCustomFunction	Special

let b:current_syntax = "opl"
" vim: ts=8
