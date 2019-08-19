"==============================================================================
" This file provides some function to help insert some templates into C/C++ 
" files. 
"==============================================================================
" Author: bilbopingouin
" Original date: 03.11.2014
" Modification history:
"    Date    |  Name        | Comments
"  ----------|--------------|-------------------------------
"  4.11.14   | BP           | Added function InsertPreProcIf and <leader>pi
"  18.08.2019| BP	    | Adapted to stand alone plugin
"  19.08.2019| BP	    | Merged various functions into a single file
"            |              |
"==============================================================================
" Available commands:
"  UTILITY
"   call ReadSkeleton()		    -- See the available templates and insert it
"   call s:GetToCursor()	    -- Look for <CURSOR> get into insert mode
"   call s:SetTemplValues()	    -- Set some values from the templates
"   call s:CreateScratchBuffer()    -- Create a new buffer with scratch options
"   call s:MoveScratchBufferContent() -- Yank the content of the current buffer, unload 
"				      it and paste it in the next buffer.		     
"
"  GENERIC TEMPLATE
"   <leader>rs			    -- inserts any template: interactive choice
"
"  FILES SPECIFIC
"   call IncludeVimHeaderTempl()    -- Include the template and update them
"   call CreateNewVimCfgFile()	    -- Create a new vim file including the 
"				      corresponding template
"
"   call SetCHeaderTags()	    -- Set the #ifndef ... macros
"   call IncludeCHeaderFileTempl()  -- Include the template and update them
"   call CreateNewCHeaderFile()	    -- Create a new header file including the
"				      templates
"   call SetCSourceInclude()	    -- Set the #include "header.h"
"   call IncludeCSourceFileTempl()  -- Include the template and update them
"   call CreateNewCSourceFile()	    -- Create a new C source file including the 
"				      corresponding templates
"   <leader>cch			    -- Create a new C/C++ header file
"   <leader>ccs			    -- Create a new C/C++ source file
"
"  FUNCTIONS SPECIFIC
"   call SetTemplFnValues()	    -- Update the documentation of a function
"				      with specific parameters
"   call IncludeCFunctionDoc()	    -- Include the function documentation
"   call IncludeCFunction()	    -- Include a function skeleton
"   call CreateNewCFunction()	    -- Inserts a new function with its
"				      respective documentation
"   <leader>ccf			    -- Inserts a new function
"
"
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
if exists(g:templates_configuration)
  :runtime expand(g:templates_configuration)
endif

"==============================================================================
"   UTILITY FUNCTIONS
"==============================================================================

function! ReadSkeleton()
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
      :normal zO	 " otherwise deletes 19 lines
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

  if search("|AUTHOR|") != 0
    :echo "Substitute |AUTHOR|"
    if exists("g:author_name") != 0
      :%s/|AUTHOR|/\=expand(g:author_name)/g
    else
      :%s/|AUTHOR|/\=input("Author name: ")/g
      :echo "."
    endif
  endif

  if search("|AUTHSHORT|") != 0
    :echo "Substitute |AUTHSHORT|"
    if exists("g:author_short") != 0
      :%s/|AUTHSHORT|/\=expand(g:author_short)/g
    else
      :%s/|AUTHSHORT|/\=input("Author short name: ")/g
      :echo "."
    endif
  endif
 
  if search("|EMAIL|") != 0
    :echo "Substitute |EMAIL|"
    if exists("g:author_short") != 0
      :%s/|EMAIL|/\=expand(g:author_email)/g
    else
      :%s/|EMAIL|/\=input("Email address: ")/g
      :echo "."
    endif
  endif

  if search("|COMPANY|") != 0
    :echo "Substitute |COMPANY|"
    if exists("g:author_short") != 0
      :%s/|COMPANY|/\=expand(g:author_company)/g
    else
      :%s/|COMPANY|/\=input("Company name: ")/g
      :echo "."
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

nmap <leader>rs :call ReadSkeleton()<cr>

"==============================================================================
"   FILES SPECIFIC
"==============================================================================

function! IncludeVimHeaderTempl()
  :set paste
  :execute "0r!cat ".g:templates_directory."/vimhead.vim"
  :call s:SetTemplValues()
  :call s:GetToCursor()
  :set nopaste
endfunction

"==============================================================================

function! CreateNewVimCfgFile()
  :let file_name = input("vim file name: ")
  if filereadable(file_name)
    :echo "File already exists"
  else
    :execute ":tabnew ".expand(file_name)
    :call IncludeVimHeaderTempl()
  endif
endfunction

"==============================================================================

function! SetCHeaderTags ()
  :let tag_name = substitute(toupper(expand("%:t")), '\.', '_', 'g')
  if search("|TAG|")
    :%s/|TAG|/\=expand(tag_name)
  endif
endfunction

"==============================================================================

function! IncludeCHeaderFileTempl()
  :set paste
  :execute "0r!cat ".g:templates_directory."/chead.c"
  :execute "r!cat ".g:templates_directory."/cbody.h"
  :call SetCHeaderTags()
  :call s:SetTemplValues()
  :call s:GetToCursor()
  :set nopaste
endfunction

"==============================================================================

function! CreateNewCHeaderFile()
  :let file_name = input("Header file name: ")
  if filereadable(file_name)
    :echo "File already exists"
  else
    :execute ":tabnew ".expand(file_name)
    :call IncludeCHeaderFileTempl()
  endif
endfunction

"==============================================================================

function! SetCSourceInclude ()
  :let header_name = substitute(expand("%:t"), '.c$', '.h', '')
  if search("|FILEHEADER|")
    :%s/|FILEHEADER|/\=expand(header_name)
  endif
endfunction

"==============================================================================

function! IncludeCSourceFileTempl()
  :set paste
  :execute "0r!cat ".g:templates_directory."/chead.c"
  :execute "r!cat ".g:templates_directory."/cbody.c"
  :call SetCSourceInclude ()
  :call s:SetTemplValues()
  :call s:GetToCursor()
  :set nopaste
endfunction

"==============================================================================

function! CreateNewCSourceFile()
  :let file_name = input("Source file name: ")
  if filereadable(file_name)
    :echo "File already exists"
  else
    :execute ":tabnew ".expand(file_name)
    :call IncludeCSourceFileTempl()
  endif
endfunction

"==============================================================================

nmap <leader>cch  :call CreateNewCHeaderFile()<CR>
nmap <leader>ccs  :call CreateNewCSourceFile()<CR>


"==============================================================================
"   FUNCTIONS SPECIFIC
"==============================================================================

" Defaults initialisation
let s:function_name   = "|FUNCTION NAME|"
let s:function_retval = "None"
let s:param_list      = [["name","type"]]

"==============================================================================

function! SetTemplFnValues()
  if search("|FUNCTION NAME|") != 0
    :%s/|FUNCTION NAME|/\=expand(s:function_name)/g
  endif

  if search("RETVAL") != 0
    :%s/|RETVAL|/\=expand(s:function_retval)/g
  endif

  if search("|PARAM DESC|") != 0
    if len(s:param_list) == 0
      /|PARAM DESC|
      :execute "normal! 0c$   *   @param   none"
    else
      /|PARAM DESC|
      :delete
      :.-1
      :let i=0
      while i<len(s:param_list)
	:execute "normal! o   *   @param   ".s:param_list[i][0]."  description"
	:let i=i+1
      endwhile
    endif
  endif

  if search("|PARAM TYPE|") != 0
    if len(s:param_list) == 0
      /|PARAM TYPE|
      :execute "normal! 0c$   *   @tparam  none"
    else
      /|PARAM TYPE|
      :delete
      :.-1
      :let i=0
      while i<len(s:param_list)
	:execute "normal! o   *   @tparam  ".s:param_list[i][0]."  ".s:param_list[i][1]
	:let i=i+1
      endwhile
    endif
  endif
endfunction

"==============================================================================

function! IncludeCFunctionDoc()
  :set paste
  :execute "r!cat ".g:templates_directory."/cfunc.c"
  :%foldopen!
  :call s:SetTemplValues()
  :call SetTemplFnValues()
  :set nopaste
endfunction

"==============================================================================

function! IncludeCFunction()
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

function! CreateNewCFunction()
  :set paste
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

  :call s:CreateScratchBuffer()
  :call IncludeCFunction()
  :call IncludeCFunctionDoc()
  :let s:has_cursor = search("<CURSOR>")
  :call s:MoveScratchBufferContent()
  :set nopaste
  if s:has_cursor != 0
    :call s:GetToCursor()
  endif
endfunction

"==============================================================================

nmap <leader>ccf  :call	CreateNewCFunction()<CR>

