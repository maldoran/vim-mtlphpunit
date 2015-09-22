if exists("g:loaded_mtlphpunit_plugin")
  finish
endif
let g:loaded_mtlphpunit_plugin = 1

if !exists("g:mtlphpunit_command")
  let s:cmd = "phpunit {test}"
  let g:mtlphpunit_command = "!echo " . s:cmd . " && " . s:cmd
endif

function! PHPUnitRunCurrentFile()
  let l:file = substitute(expand('%:p'), '\\', '\\\\', 'g')
  if l:file !~# 'Test\.php$'
    let l:file = substitute(l:file, '\.php$', 'Test.php', '')
    let l:file = substitute(l:file, get(b:, 'mtlphpunit_path_substitue_fromdir', 'application'), get(b:, 'mtlphpunti_path_substitue_todir', 'tests'), '')
  endif
  call s:SetPreviousTest(l:file)
  call s:PHPUnitRun(l:file)
endfunction

function! PHPUnitRunCurrentTest()
  let l:file = substitute(expand('%:p'), '\\', '\\\\', 'g')
  let l:test = " --filter " . expand("<cword>") . " " . l:file
  call s:SetPreviousTest(l:test)
  call s:PHPUnitRun(l:test)
endfunction

function! PHPUnitRunPreviousTest()
  if exists("s:previous_test")
    call s:PHPUnitRun(s:previous_test)
  endif
endfunction

function! s:SetPreviousTest(test)
  let s:previous_test = a:test
endfunction

function! PHPUnitRunAllTests()
  if exists("b:mtlphpunit_command_all")
    let l:output = system(b:mtlphpunit_command_all)

    if v:shell_error
      echohl Error | echo l:output | echohl None
    else
      let l:nbLines = len(split(l:output, '\n'))

      echohl Title | echo l:output | echohl None
    endif
  else
    echohl Error | echo "b:mtlphpunit_command_all is not set" | echohl None
  endif
endfunction

function! s:PHPUnitRun(test)
  let l:mtlphpunit_command = get(b:, 'mtlphpunit_command', g:mtlphpunit_command) . " {test}"
  let l:command = substitute(l:mtlphpunit_command, "{test}", a:test, "g")
  let l:output = system(l:command)

  if v:shell_error
    echohl Error | echo l:output | echohl None
  else
    let l:nbLines = len(split(l:output, '\n'))

    echohl Title | echo l:output | echohl None
  endif

endfunction

:noremap <leader>puf :call PHPUnitRunCurrentFile()<cr>
:noremap <leader>put :call PHPUnitRunCurrentTest()<cr>
:noremap <leader>pup :call PHPUnitRunPreviousTest()<cr>
:noremap <leader>pua :call PHPUnitRunAllTests()<cr>

" set in the projects .local.vimrc
"let b:mtlphpunit_command = fnameescape($GIT_ENVIRONMENT) . "\\LWHWMS\\vendor\\bin\\phpunit.bat --bootstrap " . fnameescape($GIT_ENVIRONMENT) . "\\LWHWMS\\tests\\bootstrap.php"
"let b:mtlphpunit_command_all = fnameescape($GIT_ENVIRONMENT) . "\\LWHWMS\\vendor\\bin\\phpunit.bat --configuration " . fnameescape($GIT_ENVIRONMENT) . "\\LWHWMS\\tests\\phpunit.xml"

