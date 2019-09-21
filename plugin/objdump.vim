if exists('g:loaded_objdump')
    finish
endif

let g:loaded_objdump = 1

let s:cmd_per_arch = {
    \ 0x08: 'mipsel-linux-gnu-objdump',
    \ 0x28: 'arm-linux-gnueabihf-objdump',
    \ 0x3E: 'x86_64-linux-gnu-objdump -Mintel',
    \ 0xB7: 'aarch64-linux-gnu-objdump',
    \ 0xF3: 'riscv64-linux-gnu-objdump',
    \ }

func! objdump#disasm(file) abort
    let file = substitute(a:file, '^objdump://', '', '')

    " Read in the ELF header
    let header = readfile(file, 'B', 0x40)

    " Make sure it's a valid ELF file
    if len(header) < 0x40 || header[:3] != 0z7F454C46
	echoerr 'Not an ELF file'
	return
    endif

    " Read the e_machine field
    let arch = (header[0x13]) * 256 + (header[0x12])

    if !has_key(s:cmd_per_arch, arch)
	echoerr 'No command registered for this architecture'
	return
    endif

    setl ma
    exe 'keepj sil r! ' . s:cmd_per_arch[arch] . ' -d -- ' . shellescape(file, 1)
    norm! gg
    setl ro noma buftype=nofile bufhidden=hide nobuflisted
    setf objdump
endf

augroup obj
    au!
    au BufReadCmd objdump://* call objdump#disasm(expand('<amatch>'))
augroup END

command! -nargs=? -complete=file Obj exe 'e objdump://' . <q-args>
