if exists('g:loaded_denops_startup_recorder')
  finish
endif
let g:loaded_denops_startup_recorder = 1

augroup denops_startup_recorder
  autocmd!
  autocmd User DenopsReady call denops_startup_recorder#_on_ready()
  autocmd User DenopsSystemPluginPre:* call denops_startup_recorder#_on_event('pre')
  autocmd User DenopsSystemPluginPost:* call denops_startup_recorder#_on_event('post')
  autocmd VimEnter * call denops_startup_recorder#_on_load()
augroup END

