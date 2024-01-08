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
        let l:event.start = reltime(l:basetime, l:reltime)
      elseif l:event_name ==# 'DenopsPluginPost'
        let l:event.end = reltime(l:basetime, l:reltime)
      endif
      let l:events[l:plugin_name] = l:event
    else
      let l:events[l:event_name] = #{
            \ start: reltime(l:basetime, l:reltime),
            \}
    endif
  endfor
  let l:events = map(items(l:events), { _, v -> [v[0], s:format_event(v[1])] })
  let l:events = sort(l:events, { e1, e2 -> s:compare_event_infos(e1[1], e2[1]) })
  return l:events
endfunction

function! denops_startup_recorder#display_events() abort
  let l:events = map(
        \ denops_startup_recorder#events(),
        \ { _, v -> [v[0], s:display_event(v[1])] },
        \)
  let l:longest_name = max(map(copy(l:events), { _, v -> len(v[0]) }))
  let l:longest_start = max(map(copy(l:events), { _, v -> len(v[1].start_display) }))
  let l:longest_duration = max(map(copy(l:events), { _, v -> len(get(v[1], 'duration_display', '')) }))
  let l:format_expr = printf('%%%ds  %%%ds  %%%ds', l:longest_name, l:longest_start, l:longest_duration)
  let l:Format = { v -> printf(l:format_expr, v[0], v[1].start_display, get(v[1], 'duration_display', '')) }
  let l:head_length = l:longest_name + l:longest_start + l:longest_duration + 4
  let l:tail_length = &columns - l:head_length - 3
  let l:last_time = l:events[-1][1].end
  let l:ratio = l:tail_length / l:last_time
  redraw
  echo repeat('─', &columns - 1)
  echo printf(l:format_expr, 'Name', 'Start', 'Duration')
  echo repeat('─', &columns - 1)
  for l:event in l:events
    echo l:Format(l:event) .. '  ' .. s:display_event_bar(l:event[1], l:ratio, l:tail_length) .. ''
  endfor
  echo repeat('─', &columns - 1)
endfunction

function! s:compare_event_infos(i1, i2) abort
  return a:i1.start == a:i2.start ? 0 : a:i1.start > a:i2.start ? 1 : -1
endfunction

function! s:format_event(event) abort
  let l:event = #{
        \ start: reltimefloat(a:event.start),
        \}
  if has_key(a:event, 'end')
    let l:event.end = reltimefloat(a:event.end)
    let l:event.duration = reltimefloat(reltime(a:event.start, a:event.end))
  endif
  return l:event
endfunction

function! s:display_event(event) abort
  let l:event = #{
        \ start: a:event.start,
        \ start_display: printf('%.6f ms', a:event.start * 1000),
        \}
  if has_key(a:event, 'end')
    let l:event.end = a:event.end
    let l:event.end_display = printf('%.6f ms', a:event.end * 1000)
  endif
  if has_key(a:event, 'duration')
    let l:event.duration = a:event.duration
    let l:event.duration_display = printf('%.6f ms', a:event.duration * 1000)
  endif
  return l:event
endfunction

function! s:display_event_bar(event, ratio, width) abort
  let l:bar = repeat('▓', has_key(a:event, 'duration') ? float2nr(a:event.duration * a:ratio) : 1)
  let l:bar = l:bar ==# '' ? '▓' : l:bar
  let l:leading = repeat('░', float2nr(a:event.start * a:ratio))
  let l:trailing = repeat('░', a:width - strdisplaywidth(l:leading) - strdisplaywidth(l:bar))
  return l:leading .. l:bar .. l:trailing
endfunction
