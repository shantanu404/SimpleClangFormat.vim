" Create custom command to format code with clang-format
exec "command! -range=% -nargs=? ClangFormat <line1>,<line2>call s:SimpleClangFormat('<args>')"

function! s:SimpleClangFormat(...) range
	if !executable('clang-format')
		echo "[ERROR] clang-format not found in path. Is it installed?"
		return -1
	endif
	let l:options = ''
	if a:0 > 1
		echo "[ERROR] multiple arguments are not supported"
		return -1
	endif
	if a:0 == 0 || a:1 == ''
		if exists('g:SimpleClangFormat#options')
			let l:options = s:ParseClangOptions(g:SimpleClangFormat#options)
		else
			let l:options = 'llvm'
		endif
	elseif a:1 ==? "LLVM" || a:1 ==? "Google" || a:1 ==? "Chromium" || a:1 ==? "Mozilla" || a:1 ==? "WebKit" || a:1 ==? "File"
		let l:options = a:1
	endif
	if exists('g:SimpleClangFormat#userStyles') && has_key(g:SimpleClangFormat#userStyles, a:1)
		let l:options = s:ParseClangOptions(g:SimpleClangFormat#userStyles[a:1])
	else
		" handle options directly
		if l:options =~ '\v\{.*\}'
			let l:options = s:ParseClangOptions(a:1)
		else
			echo "[ERROR] Wrong style options"
			return -1
		endif
	endif
	let l:options = s:ApplyUserIndentationSettings(l:options)
	exec a:firstline.",".a:lastline."!clang-format -style=".l:options
	return 0
endfunction

function! s:ApplyUserIndentationSettings(options)
	if exists('g:SimpleClangFormat#useShiftWidth')
		if g:SimpleClangFormat#useShiftWidth == 1
			let l:options = substitute(a:options, '}', ', IndentWidth: '.&shiftwidth.'}', &gdefault ? 'gg' : 'g')
		endif
	endif
	if exists('g:SimpleClangFormat#useTabStop')
		if g:SimpleClangFormat#useTabStop == 1
			let l:options = substitute(a:options, '}', ', TabWidth: '.&tabstop.'}', &gdefault ? 'gg' : 'g')
		endif
	endif
	return l:options
endfunction

function! s:ParseClangOptions(options)
	let l:tmp = substitute(string(a:options), "'", "", &gdefault ? 'gg' : 'g')
	return "'".l:tmp."'"
endfunction
