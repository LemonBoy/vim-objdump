if exists('g:loaded_objdump')
    finish
endif

let g:loaded_objdump = 1

if !exists('g:objdump_extra_args')
    let g:objdump_extra_args = ''
endif

func! s:get_objdump_path() abort
    if executable('llvm-objdump')
	return 'llvm-objdump'
    endif

    for ver in range(10, 6, -1)
	let exe = 'llvm-objdump-' . ver
	if executable(exe)
	    return exe
	endif
    endfor

    return ''
endfunc

func! objdump#disasm(file) abort
    let file = substitute(a:file, '^objdump://', '', '')

    " Read in the ELF header
    let header = readfile(file, 'B', 0x40)

    " Make sure it's a valid ELF file
    if len(header) < 0x40 || header[:3] != 0z7F454C46
	echoerr 'Not an ELF file'
	return
    endif

    let objdump_exe = s:get_objdump_path()
    if len(objdump_exe) == 0
	echoerr 'Could not find LLVM objdump binary'
	return
    endif

    setl ma
    exe 'keepj sil r! ' . objdump_exe . ' -d ' . g:objdump_extra_args . ' -- ' . shellescape(file, 1)
    norm! gg
    setl ro noma buftype=nofile bufhidden=hide
    setf objdump
endf

augroup obj
    au!
    au BufReadCmd objdump://* call objdump#disasm(expand('<amatch>'))
augroup END

command! -nargs=? -complete=file Obj exe 'e objdump://' . <q-args>
