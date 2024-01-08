function! denops_startup_recorder#events() abort
  const l:basetime = g:denops_startup_recorder_basetime
  let l:records = deepcopy(g:denops_startup_recorder_records)
  let l:events = {}
  for [l:event_name, l:reltime] in l:records
    let l:m = matchlist(l:event_name, '^\(.\+\):\(.\+\)$')
    if !empty(l:m)
      let l:event_name = l:m[1]
      let l:plugin_name = l:m[2]
      let l:event = get(l:events, l:plugin_name, {})
      if l:event_name ==# 'DenopsPluginPre'
        let l:event.plugin_start = reltime(l:basetime, l:reltime)
      elseif l:event_name ==# 'DenopsPluginPost'
        let l:event.plugin_end = reltime(l:basetime, l:reltime)
      elseif l:event_name ==# 'DenopsPluginWorkerPre'
        let l:event.worker_start = reltime(l:basetime, l:reltime)
      elseif l:event_name ==# 'DenopsPluginWorkerPost'
        let l:event.worker_end = reltime(l:basetime, l:reltime)
      endif
      let l:events[l:plugin_name] = l:event
    else
      let l:events[l:event_name] = #{ start: reltime(l:basetime, l:reltime) }
    endif
  endfor
  let l:events = map(items(l:events), { _, v -> s:normalize_event(v[0], v[1]) })
  let l:events = sort(l:events, { e1, e2 -> s:compare_events(e1, e2) })
  return l:events
endfunction

function! denops_startup_recorder#display_events(...) abort
  let l:width = a:0 ? a:1 : &columns
  let l:events = map(
        \ denops_startup_recorder#events(),
        \ { _, v -> s:display_event(v) },
        \)
  echo l:events
  let l:longest_name = max(map(copy(l:events), { _, v -> len(v.name) }))
  let l:longest_start = max(map(copy(l:events), { _, v -> len(v.start_display) }))
  let l:longest_end = max(map(copy(l:events), { _, v -> len(v.end_display) }))
  let l:longest_dur = max(map(copy(l:events), { _, v -> len(v.dur_display) }))
  let l:label_format = printf('%%%ds  %%%ds  %%%ds  %%%ds', l:longest_name, l:longest_start, l:longest_end, l:longest_dur)
  let l:Format = { v -> printf(l:label_format, v.name, v.start_display, v.end_display, v.dur_display) }
  let l:head_length = len(printf(l:label_format, '', '', '', ''))
  let l:tail_length = l:width - l:head_length - 3
  let l:last_time = s:max(map(copy(l:events), { _, v -> v.end }))
  let l:ratio = l:tail_length / l:last_time
  redraw
  echo repeat('─', &columns - 1)
  echo printf(l:label_format, 'Name', 'Start', 'End', 'Duration')
  echo repeat('─', &columns - 1)
  for l:event in l:events
    echo l:Format(l:event) .. '  ' .. s:display_event_bar(l:event, l:ratio, l:tail_length) .. ''
  endfor
  echo repeat('─', &columns - 1)
endfunction

function! s:compare_events(e1, e2) abort
  return a:e1.start == a:e2.start ? 0 : a:e1.start > a:e2.start ? 1 : -1
endfunction

function! s:normalize_event(name, event) abort
  let l:event = #{ name: a:name }
  if has_key(a:event, 'start')
    let l:event.start = reltimefloat(a:event.start)
    let l:event.end = l:event.start
    let l:event.dur = 0
  elseif has_key(a:event, 'plugin_start') && has_key(a:event, 'worker_start')
    let l:event.plugin_start = reltimefloat(a:event.plugin_start)
    let l:event.plugin_end = reltimefloat(a:event.plugin_end)
    let l:event.plugin_dur = reltimefloat(reltime(a:event.plugin_start, a:event.plugin_end))
    let l:event.worker_start = reltimefloat(a:event.worker_start)
    let l:event.worker_end = reltimefloat(a:event.worker_end)
    let l:event.worker_dur = reltimefloat(reltime(a:event.worker_start, a:event.worker_end))
    let l:event.start = l:event.worker_start
    let l:event.end = l:event.plugin_end
    let l:event.dur = reltimefloat(reltime(a:event.worker_start, a:event.plugin_end))
  elseif has_key(a:event, 'plugin_start')
    let l:event.plugin_start = reltimefloat(a:event.plugin_start)
    let l:event.plugin_end = reltimefloat(a:event.plugin_end)
    let l:event.plugin_dur = reltimefloat(reltime(a:event.plugin_start, a:event.plugin_end))
    let l:event.start = l:event.plugin_start
    let l:event.end = l:event.plugin_end
    let l:event.dur = reltimefloat(reltime(a:event.plugin_start, a:event.plugin_end))
  else
    throw printf('Unexpected event is found: %s', string(a:event))
  endif
  return l:event
endfunction

function! s:display_event(event) abort
  let l:event = extend(deepcopy(a:event), #{
        \ start_display: printf('%.6f ms', a:event.start * 1000),
        \ end_display: printf('%.6f ms', a:event.end * 1000),
        \ dur_display: a:event.dur is# 0 ? '' : printf('%.6f ms', a:event.dur * 1000),
        \})
  if has_key(a:event, 'plugin_start')
    let l:event.plugin_start_display = printf('%.6f ms', a:event.plugin_start * 1000)
    let l:event.plugin_end_display = printf('%.6f ms', a:event.plugin_end * 1000)
    let l:event.plugin_dur_display = printf('%.6f ms', a:event.plugin_dur * 1000)
  endif
  if has_key(a:event, 'worker_start')
    let l:event.worker_start_display = printf('%.6f ms', a:event.worker_start * 1000)
    let l:event.worker_end_display = printf('%.6f ms', a:event.worker_end * 1000)
    let l:event.worker_dur_display = printf('%.6f ms', a:event.worker_dur * 1000)
  endif
  return l:event
endfunction

function! s:display_event_bar(event, ratio, width) abort
  if has_key(a:event, 'plugin_start') && has_key(a:event, 'worker_start')
    let l:worker_bar = repeat('▒', float2nr(a:event.worker_dur * a:ratio))
    let l:worker_bar = l:worker_bar ==# '' ? '▒' : l:worker_bar
    let l:plugin_bar = repeat('▓', float2nr(a:event.plugin_dur * a:ratio))
    let l:plugin_bar = l:plugin_bar ==# '' ? '▓' : l:plugin_bar
    let l:bar = l:worker_bar .. l:plugin_bar
  elseif has_key(a:event, 'plugin_start')
    let l:bar = repeat('▓', float2nr(a:event.plugin_dur * a:ratio))
    let l:bar = l:bar ==# '' ? '▓' : l:bar
  else
    let l:bar = repeat('▓', float2nr(a:event.dur * a:ratio))
    let l:bar = l:bar ==# '' ? '▓' : l:bar
  endif
  let l:leading = repeat('░', float2nr(a:event.start * a:ratio))
  let l:trailing = repeat('░', a:width - strdisplaywidth(l:leading) - strdisplaywidth(l:bar))
  return l:leading .. l:bar .. l:trailing
endfunction

" NOTE: max() does not support 'float' thus we need to define our own.
function! s:max(arr) abort
  let l:max = a:arr[0]
  for l:elem in a:arr
    if l:elem > l:max
      let l:max = l:elem
    endif
  endfor
  return l:max
endfunction
