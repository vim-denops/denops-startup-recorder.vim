let s:load_reltime = v:null
let s:ready_reltime = v:null
let s:plugin_reltimes = {}

function! denops_startup_recorder#get() abort
  let l:plugin_times = {}
  for [l:plugin_name, l:plugin_reltime] in items(s:plugin_reltimes)
    let l:plugin_time = {}
    for [l:event_name, l:event_reltime] in items(l:plugin_reltime)
      let l:plugin_time[l:event_name] = reltimefloat(reltime(s:load_reltime, l:event_reltime))
    endfor
    let l:plugin_times[l:plugin_name] = l:plugin_time
  endfor
  return {
    \ 'ready': reltimefloat(reltime(s:load_reltime, s:ready_reltime)),
    \ 'plugins': l:plugin_times,
    \}
endfunction

function! denops_startup_recorder#display() abort
  let l:info = denops_startup_recorder#get()
  let l:records = []
  for [l:plugin_name, l:plugin_time] in items(l:info['plugins'])
    let l:load = l:plugin_time['pre'] - get(l:plugin_time, 'register', l:plugin_time['pre'])
    let l:init = l:plugin_time['post'] - l:plugin_time['pre']
    call add(l:records, [l:plugin_name, l:plugin_time['post'], l:load, l:init])
  endfor
  let l:records = sort(l:records, {a, b -> a[1] == b[1] ? 0 : a[1] > b[1] ? 1 : -1 })
  let l:longest = max(map(copy(l:records), {_, v -> len(v[0])}))
  let l:content = []
  for [l:plugin_name, l:ready, l:load, l:init] in l:records
    let l:plugin_name = printf('%-*s', l:longest, l:plugin_name)
    call add(l:content, printf(
          \ '%s : %.3f s (load: %.3f s, init: %.3f s)',
          \ l:plugin_name,
          \ l:ready,
          \ l:load,
          \ l:init,
          \))
  endfor
  call add(l:content, printf('(DenopsReady: %.3f s)', l:info['ready']))
  vertical new
  call setline(1, l:content)
  setlocal buftype=nofile nomodifiable nomodified
endfunction

function! denops_startup_recorder#_on_load() abort
  let s:load_reltime = reltime()
endfunction

function! denops_startup_recorder#_on_ready() abort
  let s:ready_reltime = reltime()
endfunction

function! denops_startup_recorder#_on_event(event_name) abort
  let l:plugin_name = s:extract_plugin_name(expand('<amatch>'))
  let l:plugin_reltime = get(s:plugin_reltimes, l:plugin_name, {})
  let l:plugin_reltime = extend(l:plugin_reltime, { a:event_name : reltime() })
  let s:plugin_reltimes[l:plugin_name] = l:plugin_reltime
endfunction

function! s:extract_plugin_name(bufname) abort
  return substitute(a:bufname, '[^:]\+:', '', '')
endfunction
