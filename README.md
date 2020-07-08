# vim-prog-template

Template handling for ViM

## Install

Use a plugin manager for vim.

## Usage

Basically, there are mostly 4 commands. One generic

- `<leader>rs`: search the `template` directory, and insert the selected file

and three focusing on C/C++ files

- `<leader>ccs`: Create a source file combining the `templates/chead.c` and `templates/cbody.c` files
- `<leader>cch`: Create a header file combining the `templates/chead.c` and `templates/cbody.h` files
- `<leader>ccf`: Create a new function with a function header (`templates/cfunc.c`)

For the templates used in the last three, the plugin can perform some substitutions. In particular, it will look for the for following tags:

- `|YEAR|`
  The current year (from strftime)
- `|DATE|`
  The current date (from strftime)
- `|TIME|`
  The current time (from strftime)
- `|FILENAME|`
  The current filename
- `|MODULE|`
  
- `|AUTHOR|`
  The author name (from `g:author_name`)
- `|AUTHSHORT|`
  The author initial (from `g:author_short`)
- `|EMAIL|`
  The author email address (from `g:author_email`)
- `|COMPANY|`
  The company (from: `g:author_company`)
- `|ADDRESS|`
  The address of the company (from `g:author_company_address`)
- `|NAMESPACE|`
  The root-name of the file, or the part preceding a `_`
- `|FUNCTION NAME|
  The name of the new function
- `|RETVAL|` 
  The function's return value
- `|PARAM DESC|`
  The parameters of the function
- `|PARAM TYPE|`
  The type of the parameters
- `<CURSOR>`
  Where the cursor ends after inserting the template


