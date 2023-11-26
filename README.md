# denops-startup-recorder

A [denops][denops] plugin to record startup performance of denops plugins.

[denops]: https://github.com/vim-denops/denops.vim

Call `denops_startup_recorder#display()` to open a result buffer.

```
:call denops_startup_recorder#display()
```

It opens a result buffer like below.

```
example-minimal  : 0.278 s (load: 0.204 s, init: 0.003 s)
kensaku          : 0.278 s (load: 0.205 s, init: 0.003 s)
ddu              : 0.278 s (load: 0.209 s, init: 0.003 s)
debug            : 0.278 s (load: 0.205 s, init: 0.003 s)
issue268         : 0.279 s (load: 0.205 s, init: 0.003 s)
ansi_escape_code : 0.280 s (load: 0.205 s, init: 0.003 s)
silicon          : 0.280 s (load: 0.206 s, init: 0.003 s)
error-test       : 0.280 s (load: 0.206 s, init: 0.003 s)
butler           : 0.280 s (load: 0.206 s, init: 0.003 s)
denops-benchmark : 0.280 s (load: 0.206 s, init: 0.003 s)
deno-cache       : 0.281 s (load: 0.206 s, init: 0.003 s)
guise            : 0.283 s (load: 0.206 s, init: 0.006 s)
example-standard : 0.283 s (load: 0.206 s, init: 0.006 s)
askpass          : 0.284 s (load: 0.205 s, init: 0.008 s)
ai-example       : 0.439 s (load: 0.366 s, init: 0.001 s)
skkeleton        : 0.447 s (load: 0.374 s, init: 0.002 s)
fuzzy-motion     : 0.453 s (load: 0.380 s, init: 0.002 s)
gin              : 0.480 s (load: 0.406 s, init: 0.002 s)
(DenopsReady: 0.072 s)
```

The results reveal:

- Duration from the initiation of Vim to the effective availability of plugins.<br>`DenopsPluginPost:* - VimEnter`
- Elapsed time from when Denops registers the plugin to the complete loading of the plugin script (`load`).<br>`DenopsPluginPre:* - DenopsPluginRegister:*`
- Time passed from the full loading of the plugin script to the complete initialization of the plugin (`init`).<br>`DenopsPluginPost:* - DenopsPluginPre:*`
- Time taken by Vim from loading Denops to rendering Denops fully operational.<br>`DenopsReady - VimEnter`

> [!NOTE]
> The `load` value may be `0.000 ms` on denops.vim versions that do not yet support the `DenopsPluginRegister` autocmd.
> Upgrading denops.vim itself will resolve this issue.

## License

The code follows MIT license written in [LICENSE](./LICENSE). Contributors need
to agree that any modifications sent in this repository follow the license.
