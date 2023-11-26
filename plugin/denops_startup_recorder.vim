if exists('g:loaded_denops_startup_recorder')
  finish
endif
let g:loaded_denops_startup_recorder = 1

augroup denops_startup_recorder
  autocmd!
  autocmd User DenopsReady call denops_startup_recorder#_on_ready()
  autocmd User DenopsPluginRegister:* call denops_startup_recorder#_on_event('register')
  autocmd User DenopsPluginPre:* call denops_startup_recorder#_on_event('pre')
  autocmd User DenopsPluginPost:* call denops_startup_recorder#_on_event('post')
augroup END

call denops_startup_recorder#_on_load()
