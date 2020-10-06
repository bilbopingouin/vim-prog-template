"==============================================================================
" This file provides some function to help insert some templates into C/C++ 
" files. 
"==============================================================================
" Author: bilbopingouin
" Original date: 03.11.2014
"==============================================================================
" Notes
"   ReadSkeleton using:
"    http://vim.1045645.n5.nabble.com/How-to-insert-text-via-script-function-call-td1153378.html
"==============================================================================


"==============================================================================
"   GENERAL CONFIGURATION
"==============================================================================


" Directory where the templates are stored
let g:templates_directory = get(g:, 'templates_directory', expand("<sfile>:h:h")."/templates")

" Insert any of the template defined in the directory
let Skeleton_path = g:templates_directory 

" Configuration file
if exists("g:templates_configuration")
  :runtime expand(g:templates_configuration)
endif

"==============================================================================
"   UTILITY FUNCTIONS
"==============================================================================

function! s:ReplaceOccurences(tag, variable, input)
  :echo "Looking for ".a:tag
  if search(a:tag) != 0
    :echo "Substitute ".a:tag
    if exists(a:variable)
      :exec "let l:tmp = expand(".a:variable.")"
      :exec ":%s/".a:tag."/".l:tmp."/g"
    else
      if !empty(a:input)
        :exec ":%s/".a:tag."/\=input(\"".a:input.": \")/g"
        :echo "."
      else
	if !empty(a:variable)
	  :exec ":%s/".a:tag."/".a:variable."/g"
	endif " empty
      endif " empty
    endif " exists
  endif	" search
endfunction

function! code_templates#ReadSkeleton()
  if exists ("g:Skeleton_path")
    let skeleton_path = g:Skeleton_path
  else
    let skeleton_path = getcwd()
  endif

  let filenameList = split (glob ( skeleton_path . "/*.*") , "\n")
  let filenameList = insert (filenameList, "Select skeleton to load")
  let choiceList = copy (filenameList)
  let choiceList = map (choiceList, 'index(filenameList,v:val) .". ". v:val')
  let choiceList[0] = "Select skeleton to load"
  let listLen = len(choiceList)
  let choiceList = add (choiceList, listLen . ". Browse for some other folder (gui ONLY)")
  let choice = inputlist(choiceList)

  let skeletonName = ""
  if choice == listLen
    "Do the browse thingie if possible
    if has("browse")
      let skeletonName = browse(0,"Select session to restore",skeleton_path,"")
      echo skeletonName
    endif
  elseif choice > 0
    "Load the file
    let skeletonName = filenameList[choice]
    echo "setting skeletonName to ".skeletonName
  endif
  if skeletonName != ""
    execute "0read " . skeletonName
    call s:SetTemplValues()
  endif
endfunction

"==============================================================================

function! s:GetToCursor()
  if search("<CURSOR>") != 0
    :echo "Reaching <CURSOR>"
    :call search("<CURSOR>")
    if foldlevel(".")>0
      :normal zO	 " otherwise several lines
    endif
    :normal 8x
    :startinsert
  endif
endfunction

"==============================================================================

function! s:SetTemplValues()
  if search("|YEAR|") != 0
    :echo "Substitute |YEAR|"
    :%s/|YEAR|/\=strftime("%Y")/g
  endif

  if search("|DATE|") != 0
    :echo "Substitute |DATE|"
    :%s/|DATE|/\=strftime("%Y-%m-%d")/g
  endif

  if search("|TIME|") != 0
    :echo "Substitute |TIME|"
    :%s/|TIME|/\=strftime("%H:%M")/g
  endif

  if search("|FILENAME|") != 0
    :echo "Substitute |FILENAME|"
    :%s/|FILENAME|/\=expand("%:t")/g
  endif

  if search("|MODULE|") != 0
    :echo "Substitute |MODULE|"
    ":%s/|MODULE|/\=input("Module name: ")/g
    :%s/|MODULE|/\=expand("%:t:r")/g
    ":echo "."
  endif

  " if search("|AUTHOR|") != 0
  "   :echo "Substitute |AUTHOR|"
  "   if exists("g:author_name") != 0
  "     :%s/|AUTHOR|/\=expand(g:author_name)/g
  "   else
  "     :%s/|AUTHOR|/\=input("Author name: ")/g
  "     :echo "."
  "   endif
  " endif
  :call s:ReplaceOccurences("|AUTHOR|", expand('g:author_name'), "Author name")

  " if search("|AUTHSHORT|") != 0
  "   :echo "Substitute |AUTHSHORT|"
  "   if exists("g:author_short") != 0
  "     :%s/|AUTHSHORT|/\=expand(g:author_short)/g
  "   else
  "     :%s/|AUTHSHORT|/\=input("Author short name: ")/g
  "     :echo "."
  "   endif
  " endif
  :call s:ReplaceOccurences("|AUTHORSHORT|", 'g:author_short', "Author short name")
 
  " if search("|EMAIL|") != 0
  "   :echo "Substitute |EMAIL|"
  "   if exists("g:author_email") != 0
  "     :%s/|EMAIL|/\=expand(g:author_email)/g
  "   else
  "     :%s/|EMAIL|/\=input("Email address: ")/g
  "     :echo "."
  "   endif
  " endif
  :call s:ReplaceOccurences("|EMAIL|", 'g:author_email', "Email address")

  " if search("|COMPANY|") != 0
  "   :echo "Substitute |COMPANY|"
  "   if exists("g:author_company") != 0
  "     :%s/|COMPANY|/\=expand(g:author_company)/g
  "   else
  "     :%s/|COMPANY|/\=input("Company name: ")/g
  "     :echo "."
  "   endif
  " endif
  :call s:ReplaceOccurences("|COMPANY|", 'g:author_company', "Company name")

  " if search("|ADDRESS|") != 0
  "   :echo "Substitute |ADDRESS|"
  "   if exists("g:author_company_address") != 0
  "     :%s/|ADDRESS|/\=expand(g:author_company_address)/g
  "   else
  "     :%s/|ADDRESS|/\=input("Company address: ")/g
  "     :echo "."
  "   endif
  " endif
  :call s:ReplaceOccurences("|ADDRESS|", 'g:author_company_address', "Company address")

  if search("|NAMESPACE|") != 0
    :echo "Substitute |NAMESPACE|"
    :let l:match = match(expand('%:t:r'), '_')
    if l:match > -1
      :let l:listelements = split(expand('%:t:r'), '_')
      :%s/|NAMESPACE|/\=expand(l:listelements[0]).'_'/g
    else
      :%s/|NAMESPACE|/\=expand('%:t:r')/g
    endif
  endif
endfunction

"==============================================================================

function! s:CreateScratchBuffer()
   :new
   :setlocal buftype=nofile
   :setlocal bufhidden=hide
   :setlocal noswapfile
endfunction

"==============================================================================

function! s:MoveScratchBufferContent()
  :%y
  :bunload
  :normal P
endfunction

"==============================================================================
"   GENERIC TEMPLATE
"==============================================================================

nmap <leader>rs :call code_templates#ReadSkeleton()<cr>

"==============================================================================
"   FILES SPECIFIC
"==============================================================================

function! code_templates#IncludeVimHeaderTempl()
  :set paste
  :execute "0r!cat ".g:templates_directory."/vimhead.vim"
  :call s:SetTemplValues()
  :call s:GetToCursor()
  :set nopaste
endfunction

"==============================================================================

function! code_templates#CreateNewVimCfgFile()
  :let file_name = input("vim file name: ")
  if filereadable(file_name)
    :echo "File already exists"
  else
    :execute ":tabnew ".expand(file_name)
    :call IncludeVimHeaderTempl()
  endif
endfunction

"==============================================================================

function! code_templates#SetCHeaderTags ()
  :let tag_name = substitute(toupper(expand("%:t")), '\.', '_', 'g')
  "if search("|TAG|")
  "  :%s/|TAG|/\=expand(tag_name)
  "endif
  :call s:ReplaceOccurences("|TAG|", expand(tag_name), "")
endfunction

"==============================================================================

function! code_templates#IncludeCHeaderFileTempl()
  :set paste
  :execute "0r!cat ".g:templates_directory."/chead.c"
  :execute "r!cat ".g:templates_directory."/cbody.h"
  :call code_templates#SetCHeaderTags()
  :call s:SetTemplValues()
  :call s:GetToCursor()
  :set nopaste
endfunction

"==============================================================================

function! code_templates#CreateNewCHeaderFile()
  :let file_name = input("Header file name: ")
  if filereadable(file_name)
    :echo "File already exists"
  else
    :execute ":tabnew ".expand(file_name)
    :call code_templates#IncludeCHeaderFileTempl()
  endif
endfunction

"==============================================================================

function! code_templates#SetCSourceInclude ()
  :let header_name = substitute(expand("%:t"), '.c$', '.h', '')
  if search("|FILEHEADER|")
    :%s/|FILEHEADER|/\=expand(header_name)
  endif
endfunction

"==============================================================================

function! code_templates#IncludeCSourceFileTempl()
  :set paste
  :execute "0r!cat ".g:templates_directory."/chead.c"
  :execute "r!cat ".g:templates_directory."/cbody.c"
  :call code_templates#SetCSourceInclude ()
  :call s:SetTemplValues()
  :call s:GetToCursor()
  :set nopaste
endfunction

"==============================================================================

" This function assumes that it was called with the cursor on the old
" header
function! code_templates#UpdateCFileTempl()
  :execute "normal dap"
  :set paste
  :execute "0r!cat ".g:templates_directory."/chead.c"
  :call code_templates#SetCSourceInclude ()
  :call s:SetTemplValues()
  :call s:GetToCursor()
  :set nopaste
endfunction

"==============================================================================

function! code_templates#CreateNewCSourceFile()
  :let file_name = input("Source file name: ")
  if filereadable(file_name)
    :echo "File already exists"
  else
    :execute ":tabnew ".expand(file_name)
    :call code_templates#IncludeCSourceFileTempl()
  endif
endfunction

"==============================================================================

nmap <leader>cch  :call code_templates#CreateNewCHeaderFile()<CR>
nmap <leader>ccs  :call code_templates#CreateNewCSourceFile()<CR>


"==============================================================================
"   FUNCTIONS SPECIFIC
"==============================================================================

" Defaults initialisation
let s:function_name   = "|FUNCTION NAME|"
let s:function_retval = "None"
let s:param_list      = [["name","type"]]

"==============================================================================

function! s:SetTemplFnValues()
  if search("|FUNCTION NAME|") != 0
    :%s/|FUNCTION NAME|/\=expand(s:function_name)/g
  endif

  if search("RETVAL") != 0
    :%s/|RETVAL|/\=expand(s:function_retval)/g
  endif

  if search("|PARAM DESC|") != 0
    /|PARAM DESC|
    :let l:param_prefix=getline('.')[:match(getline('.'), '|')-1]
    if len(s:param_list) == 0
      :execute "normal! 0c$".l:param_prefix."@param   none"
    else
      :delete
      :.-1
      :let i=0
      while i<len(s:param_list)
	:execute "normal! o".l:param_prefix."@param   ".s:param_list[i][0]."  description"
	:let i=i+1
      endwhile
    endif
  endif

  if search("|PARAM TYPE|") != 0
    /|PARAM TYPE|
    :let l:param_prefix=getline('.')[:match(getline('.'), '|')-1]
    if len(s:param_list) == 0
      :execute "normal! 0c$".l:param_prefix."@param   none"
    else
      :delete
      :.-1
      :let i=0
      while i<len(s:param_list)
	:execute "normal! o".l:param_prefix."@tparam  ".s:param_list[i][0]."  ".s:param_list[i][1]
	:let i=i+1
      endwhile
    endif
  endif
endfunction

"==============================================================================

function! code_templates#IncludeCFunctionDoc()
  :set paste
  :execute "r!cat ".g:templates_directory."/cfunc.c"
  ":%foldopen! 
  """ complains if no fold is there
  """ however, the replacement of the <CURSOR> might delete the fold
  :call s:SetTemplValues()
  :call s:SetTemplFnValues()
  :set nopaste
endfunction

"==============================================================================

function! s:IncludeCFunction()
  :delm a
  :mark a
  :execute "normal! i".s:function_retval." ".s:function_name." ("
  if len(s:param_list) == 0
    :execute "normal! avoid)"
  else
    :let i=0
    while i < len(s:param_list)
      :echo i
      if i>0
        :execute "normal! a, "
      endif
      :execute "normal! a".s:param_list[i][1]." ".s:param_list[i][0]
      :let i=i+1
    endwhile
    :execute "normal! a)"
  endif
  :execute "normal! o{\n\n}"
  :execute "normal! `aO"
endfunction

"==============================================================================

function! code_templates#GetFunctionInformationFromUser()
  :let s:function_name   = input("Function name: ")
  :let s:function_retval = input("Function return type: ")

  :let param_numbers = input ("Number of parameters: ")
  :let s:param_list  = []
  :let i             =0
  if param_numbers!=0
    while i<param_numbers
      :let pname = input("Parameter ".(i+1)." name: ")
      :let ptype = input("Parameter ".(i+1)." type: ")
      :call add(s:param_list,[pname,ptype])
      :let i=i+1
    endwhile 
  endif
endfunction

"==============================================================================
" Reads the prototype of a function and extract
" the relevant data for a function header/documentation
"
function! code_templates#GetFunctionInformationFromProto()
  :let l:curline = getline('.')
  :let l:function_pattern='^\(.\+\)\ \+\([^\ ]\+\)\ *(\([^)]*\)).*'

  :let s:function_retval  = substitute(l:curline, l:function_pattern, '\1', '')
  :let s:function_name	  = substitute(l:curline, l:function_pattern, '\2', '')
  :let l:arguments	  = substitute(l:curline, l:function_pattern, '\3', '')
  ":echo l:arguments

  :let l:args = []
  if (l:arguments =~ 'void')
    ":echo 'yes'
  else
    ":echo 'no'
    :let l:args = split(substitute(l:arguments, '[()]', '', ''), ',')
  endif
  ":echo l:args

  ":execute 'normal  oreturns '.s:function_retval
  ":execute 'normal  ofunction '.s:function_name
  ":execute 'normal  oarguments '.l:arguments

  :let s:param_list  = []
  if len(l:args)>0
    :let i = 0
    while i < len(l:args)
      :let pname = substitute(l:args[i], '^\(.*\)\ \+\([^\ ]\+\)\ *', '\2', '')
      :let ptype = substitute(l:args[i], '^\(.*\)\ \+\([^\ ]\+\)\ *', '\1', '')
      :call add(s:param_list,[pname,ptype])
      :let i=i+1
    endwhile
  endif
endfunction

"==============================================================================

function! code_templates#CreateNewCFunction()
  :set paste
  :call code_templates#GetFunctionInformationFromUser()
  :call s:CreateScratchBuffer()
  :call s:IncludeCFunction()
  :call code_templates#IncludeCFunctionDoc()
  :let s:has_cursor = search("<CURSOR>")
  :call s:MoveScratchBufferContent()
  :set nopaste
  if s:has_cursor != 0
    :call s:GetToCursor()
  endif
endfunction

"==============================================================================

function! code_templates#CreateNewCFunctionDoc()
  :set paste
  :call code_templates#GetFunctionInformationFromProto()
  :call s:CreateScratchBuffer()
  ":call s:IncludeCFunction()
  :call code_templates#IncludeCFunctionDoc()
  :let s:has_cursor = search("<CURSOR>")
  :call s:MoveScratchBufferContent()
  :set nopaste
  if s:has_cursor != 0
    :call s:GetToCursor()
  endif
endfunction

"==============================================================================

nmap <leader>ccf  :call	code_templates#CreateNewCFunction()<CR>

"==============================================================================

command! -nargs=0 CTemplNewHeader     :call code_templates#CreateNewCHeaderFile()<CR>
command! -nargs=0 CTemplNewSource     :call code_templates#CreateNewCSourceFile()<CR>
command! -nargs=0 CTemplUpdHead	      :call code_templates#UpdateCFileTempl()<CR>

command! -nargs=0 CTemplNewFunction   :call code_templates#CreateNewCFunction()<CR>
command! -nargs=0 CTemplFunctionDoc   :call code_templates#CreateNewCFunctionDoc()<CR>
