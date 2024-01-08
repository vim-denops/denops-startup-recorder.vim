if exists('g:loaded_denops_startup_recorder')
  finish
endif
let g:loaded_denops_startup_recorder = 1

let g:denops_startup_recorder_basetime = reltime()
let g:denops_startup_recorder_records = []

function! s:record(name) abort
  call add(g:denops_startup_recorder_records, [a:name, reltime()])
endfunction

augroup denops_startup_recorder
  autocmd!
  autocmd VimEnter * call s:record('VimEnter')
  autocmd User DenopsReady,DenopsPluginWorkerPre:*,DenopsPluginWorkerPost:*,DenopsPluginPre:*,DenopsPluginPost:*,DenopsProcessStarted 
        \ call s:record(expand('<amatch>'))
augroup END

command! -nargs=? DenopsStartupRecorderDisplayEvents call denops_startup_recorder#display_events(<f-args>)
