if exists('g:loaded_objdump')
    finish
endif

let g:loaded_objdump = 1

func! objdump#disasm(file) abort
    let file = substitute(a:file, '^objdump://', '', '')
    if !filereadable(file)
	echohl Error | echo 'Cannot open file ' . a:file | echohl Normal
	return
    endif
    exe 'sil r! objdump -Mintel -d -- ' . shellescape(file, 1)
    norm! gg
    setl ro buftype=nofile bufhidden=hide nobuflisted
    setf objdump
endf

augroup obj
    au!
    au BufReadCmd objdump://* call objdump#disasm(expand('<amatch>'))
augroup END

command! -nargs=? -complete=file Obj call objdump#disasm(<q-args>)
