if exists("b:current_syntax")
    finish
endif

syntax case ignore

syntax match objFunc '^\x\+\s\+<\?.*>\?:$'
syntax match objRef  '<.*>$'
syntax match objNum  '$\?0[xX]\x\+'

hi def link objFunc Function
hi def link objRef  Identifier
hi def link objNum  Number

let b:current_syntax = 'objdump'
