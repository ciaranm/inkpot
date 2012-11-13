" Vim color file
" Name:       inkpot256.vim
" Maintainer: Trevor Powell <trevor@gridbug.org>
" Last Change:  November 28 2008
"
" This is a port of ciaram's inkpot color scheme to the xterm palette
" approximation code from desert256.vim, by Henry So Jr.  Gives a
" substantially better match between the appearance of gvim/macvim and console
" vim than the hand-written colors from the original.
"
" This should work in the GUI, rxvt-unicode (88 colour mode) and xterm (256
" colour mode). It won't work in 8/16 colour terminals.
"
" To use a black background, :let g:inkpot_black_background = 1

set background=dark

if version > 580
	hi clear
	if exists("syntax_on")
		syntax reset
	endif
endif

let g:colors_name = "inkpot256"

if ! exists("g:inkpot_black_background")
    let g:inkpot_black_background = 0
endif

if !has("gui_running") && &t_Co != 88 && &t_Co != 256
	finish
endif

" functions {{{
" returns an approximate grey index for the given grey level
fun <SID>grey_number(x)
	if &t_Co == 88
		if a:x < 23
			return 0
		elseif a:x < 69
			return 1
		elseif a:x < 103
			return 2
		elseif a:x < 127
			return 3
		elseif a:x < 150
			return 4
		elseif a:x < 173
			return 5
		elseif a:x < 196
			return 6
		elseif a:x < 219
			return 7
		elseif a:x < 243
			return 8
		else
			return 9
		endif
	else
		if a:x < 14
			return 0
		else
			let l:n = (a:x - 8) / 10
			let l:m = (a:x - 8) % 10
			if l:m < 5
				return l:n
			else
				return l:n + 1
			endif
		endif
	endif
endfun

" returns the actual grey level represented by the grey index
fun <SID>grey_level(n)
	if &t_Co == 88
		if a:n == 0
			return 0
		elseif a:n == 1
			return 46
		elseif a:n == 2
			return 92
		elseif a:n == 3
			return 115
		elseif a:n == 4
			return 139
		elseif a:n == 5
			return 162
		elseif a:n == 6
			return 185
		elseif a:n == 7
			return 208
		elseif a:n == 8
			return 231
		else
			return 255
		endif
	else
		if a:n == 0
			return 0
		else
			return 8 + (a:n * 10)
		endif
	endif
endfun

" returns the palette index for the given grey index
fun <SID>grey_color(n)
	if &t_Co == 88
		if a:n == 0
			return 16
		elseif a:n == 9
			return 79
		else
			return 79 + a:n
		endif
	else
		if a:n == 0
			return 16
		elseif a:n == 25
			return 231
		else
			return 231 + a:n
		endif
	endif
endfun

" returns an approximate color index for the given color level
fun <SID>rgb_number(x)
	if &t_Co == 88
		if a:x < 69
			return 0
		elseif a:x < 172
			return 1
		elseif a:x < 230
			return 2
		else
			return 3
		endif
	else
		if a:x < 75
			return 0
		else
			let l:n = (a:x - 55) / 40
			let l:m = (a:x - 55) % 40
			if l:m < 20
				return l:n
			else
				return l:n + 1
			endif
		endif
	endif
endfun

" returns the actual color level for the given color index
fun <SID>rgb_level(n)
	if &t_Co == 88
		if a:n == 0
			return 0
		elseif a:n == 1
			return 139
		elseif a:n == 2
			return 205
		else
			return 255
		endif
	else
		if a:n == 0
			return 0
		else
			return 55 + (a:n * 40)
		endif
	endif
endfun

" returns the palette index for the given R/G/B color indices
fun <SID>rgb_color(x, y, z)
	if &t_Co == 88
		return 16 + (a:x * 16) + (a:y * 4) + a:z
	else
		return 16 + (a:x * 36) + (a:y * 6) + a:z
	endif
endfun

" returns the palette index to approximate the given R/G/B color levels
fun <SID>color(r, g, b)
	" get the closest grey
	let l:gx = <SID>grey_number(a:r)
	let l:gy = <SID>grey_number(a:g)
	let l:gz = <SID>grey_number(a:b)

	" get the closest color
	let l:x = <SID>rgb_number(a:r)
	let l:y = <SID>rgb_number(a:g)
	let l:z = <SID>rgb_number(a:b)

	if l:gx == l:gy && l:gy == l:gz
		" there are two possibilities
		let l:dgr = <SID>grey_level(l:gx) - a:r
		let l:dgg = <SID>grey_level(l:gy) - a:g
		let l:dgb = <SID>grey_level(l:gz) - a:b
		let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
		let l:dr = <SID>rgb_level(l:gx) - a:r
		let l:dg = <SID>rgb_level(l:gy) - a:g
		let l:db = <SID>rgb_level(l:gz) - a:b
		let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
		if l:dgrey < l:drgb
			" use the grey
			return <SID>grey_color(l:gx)
		else
			" use the color
			return <SID>rgb_color(l:x, l:y, l:z)
		endif
	else
		" only one possibility
		return <SID>rgb_color(l:x, l:y, l:z)
	endif
endfun

" returns the palette index to approximate the 'rrggbb' hex string
fun <SID>rgb(rgb)
	let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
	let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
	let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0
	return <SID>color(l:r, l:g, l:b)
endfun

" sets the highlighting for the given group
fun <SID>X(group, fg, bg, attr)
	if a:fg != ""
		exec "hi ".a:group." guifg=#".a:fg." ctermfg=".<SID>rgb(a:fg)
	endif
	if a:bg != ""
		exec "hi ".a:group." guibg=#".a:bg." ctermbg=".<SID>rgb(a:bg)
	endif
	if a:attr != ""
		if a:attr == 'italic'
			exec "hi ".a:group." gui=".a:attr." cterm=none"
		else
			exec "hi ".a:group." gui=".a:attr." cterm=".a:attr
		endif
	endif
endfun
" }}}

    if ! g:inkpot_black_background
		call <SID>X("Normal", "cfbfad",   "1e1e27", "none")
    else
        call <SID>X("Normal", "cfbfad",   "000000", "none")
    endif

if has("gui_running")
    call <SID>X("CursorLine", "", "2e2e37", "none")
else " If running in 256 or fewer colors, this off-grey cursorline
	 " gets smashed down to just black.  If we say to use a pure grey
	 " instead, it looks closer to what was intended.
    call <SID>X("CursorLine", "", "2e2e2e", "none")
endif

    call <SID>X("IncSearch",   "303030",   "cd8b60",      "bold")
    call <SID>X("Search",   "303030",   "ad7b57",         "none")
    call <SID>X("ErrorMsg",   "ffffff",   "ce4e4e",       "bold")
    call <SID>X("WarningMsg",   "ffffff",   "ce8e4e",     "bold")
    call <SID>X("ModeMsg",   "7e7eae",   "",        "bold")
    call <SID>X("MoreMsg",   "7e7eae",   "",        "bold")
    call <SID>X("Question",   "ffcd00",   "",       "bold")

    call <SID>X("StatusLine",   "b9b9b9",   "3e3e5e",     "bold")
    call <SID>X("User1",   "00ff8b",   "3e3e5e",          "bold")
    call <SID>X("User2",   "7070a0",   "3e3e5e",          "bold")
    call <SID>X("StatusLineNC",   "b9b9b9",   "3e3e5e",   "none")
    call <SID>X("VertSplit",   "b9b9b9",   "3e3e5e",      "none")

    call <SID>X("WildMenu",   "eeeeee",   "6e6eaf",       "bold")

    call <SID>X("MBENormal",  "cfbfad",   "2e2e3f", "none")
    call <SID>X("MBEChanged", "eeeeee",   "2e2e3f", "none")
    call <SID>X("MBEVisibleNormal", "cfcfcd",   "4e4e8f", "none")
    call <SID>X("MBEVisibleChanged", "eeeeee",   "4e4e8f", "none")

    call <SID>X("DiffText",   "ffffcd",   "4a2a4a",       "none")
    call <SID>X("DiffChange",   "ffffcd",   "306b8f",     "none")
    call <SID>X("DiffDelete",   "ffffcd",   "6d3030",     "none")
    call <SID>X("DiffAdd",   "ffffcd",   "306d30",        "none")

    call <SID>X("Cursor",   "404040",   "8b8bff",         "none")
    call <SID>X("lCursor",   "404040",   "8fff8b",        "none")
    call <SID>X("CursorIM",   "404040",   "8b8bff",       "none")

    call <SID>X("Folded",   "cfcfcd",   "4b208f",         "none")
    call <SID>X("FoldColumn",   "8b8bcd",   "2e2e2e",     "none")

    call <SID>X("Directory",   "00ff8b",   "",      "none")
    call <SID>X("LineNr",   "8b8bcd",   "2e2e2e",         "none")
    call <SID>X("NonText",   "8b8bcd",   "",        "bold")
    call <SID>X("SpecialKey",   "ab60ed",   "",     "bold")
    call <SID>X("Title",   "af4f4b",   "",          "bold")
    call <SID>X("Visual",   "eeeeee",   "4e4e8f",         "none")

    call <SID>X("Comment",   "cd8b00",   "",        "none")
    call <SID>X("Constant",   "ffcd8b",   "",       "none")
    call <SID>X("String",   "ffcd8b",   "404040",         "none")
    call <SID>X("Error",   "ffffff",   "6e2e2e",          "none")
    call <SID>X("Identifier",   "ff8bff",   "",     "none")
    call <SID>X("Ignore", "", "", "none")
    call <SID>X("Number",   "f0ad6d",   "",         "none")
    call <SID>X("PreProc",   "409090",   "",        "none")
    call <SID>X("Special",   "c080d0",   "",        "none")
    call <SID>X("SpecialChar",   "c080d0",   "404040",    "none")
    call <SID>X("Statement",   "808bed",   "",      "none")
    call <SID>X("Todo",   "303030",   "d0a060",           "bold")
    call <SID>X("Type",   "ff8bff",   "",           "none")
    call <SID>X("Underlined",   "df9f2d",   "",     "bold")
    call <SID>X("TaglistTagName",   "808bed",   "", "bold")

    call <SID>X("perlSpecialMatch", "c080d0",   "404040",   "none")
    call <SID>X("perlSpecialString", "c080d0",   "404040",  "none")

    call <SID>X("cSpecialCharacter", "c080d0",   "404040",  "none")
    call <SID>X("cFormat", "c080d0",   "404040",            "none")

    call <SID>X("doxygenBrief", "fdab60",   "",                 "none")
    call <SID>X("doxygenParam", "fdd090",   "",                 "none")
    call <SID>X("doxygenPrev", "fdd090",   "",                  "none")
    call <SID>X("doxygenSmallSpecial", "fdd090",   "",          "none")
    call <SID>X("doxygenSpecial", "fdd090",   "",               "none")
    call <SID>X("doxygenComment", "ad7b20",   "",               "none")
    call <SID>X("doxygenSpecial", "fdab60",   "",               "none")
    call <SID>X("doxygenSpecialMultilineDesc", "ad600b",   "",  "none")
    call <SID>X("doxygenSpecialOnelineDesc", "ad600b",   "",    "none")

    if v:version >= 700
        call <SID>X("Pmenu",   "eeeeee",   "4e4e8f",          "none")
        call <SID>X("PmenuSel",   "eeeeee",   "2e2e3f",       "bold")
        call <SID>X("PmenuSbar",   "eeeeee",   "6e6eaf",      "bold")
        call <SID>X("PmenuThumb",   "eeeeee",   "6e6eaf",     "bold")

        hi SpellBad     gui=undercurl guisp=#cc6666
        hi SpellRare    gui=undercurl guisp=#cc66cc
        hi SpellLocal   gui=undercurl guisp=#cccc66
        hi SpellCap     gui=undercurl guisp=#66cccc

        call <SID>X("MatchParen",      "cfbfad",   "4e4e8f",   "none")
    endif
    if v:version >= 703
        call <SID>X("Conceal",      "c080d0",   "",      "none")
    endif

hi! link VisualNOS	Visual
hi! link NonText	LineNr
hi! link FoldColumn	Folded

" delete functions {{{
delf <SID>X
delf <SID>rgb
delf <SID>color
delf <SID>rgb_color
delf <SID>rgb_level
delf <SID>rgb_number
delf <SID>grey_color
delf <SID>grey_level
delf <SID>grey_number
" }}}


" vim: set et :
