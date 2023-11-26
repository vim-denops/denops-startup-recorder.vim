# denops-startup-recorder

A [denops][denops] plugin to record startup performance of denops plugins.

[denops]: https://github.com/vim-denops/denops.vim

Call `denops_startup_recorder#display()` to open a result buffer.

```
:call denops_startup_recorder#display()
```

It opens a result buffer like below.

```
example-minimal  : 0.364 ms (load: 0.227 ms, init: 0.002 ms)
kensaku          : 0.365 ms (load: 0.227 ms, init: 0.002 ms)
ddu              : 0.365 ms (load: 0.230 ms, init: 0.002 ms)
debug            : 0.365 ms (load: 0.227 ms, init: 0.002 ms)
issue268         : 0.365 ms (load: 0.227 ms, init: 0.002 ms)
ansi_escape_code : 0.365 ms (load: 0.227 ms, init: 0.002 ms)
silicon          : 0.367 ms (load: 0.228 ms, init: 0.004 ms)
error-test       : 0.367 ms (load: 0.228 ms, init: 0.003 ms)
butler           : 0.368 ms (load: 0.228 ms, init: 0.004 ms)
deno-cache       : 0.368 ms (load: 0.228 ms, init: 0.004 ms)
denops-benchmark : 0.368 ms (load: 0.228 ms, init: 0.004 ms)
guise            : 0.370 ms (load: 0.228 ms, init: 0.006 ms)
example-standard : 0.370 ms (load: 0.228 ms, init: 0.006 ms)
askpass          : 0.370 ms (load: 0.227 ms, init: 0.008 ms)
ai-example       : 0.502 ms (load: 0.364 ms, init: 0.001 ms)
fuzzy-motion     : 0.514 ms (load: 0.376 ms, init: 0.002 ms)
skkeleton        : 0.524 ms (load: 0.386 ms, init: 0.002 ms)
gin              : 0.532 ms (load: 0.393 ms, init: 0.002 ms)
(DenopsReady: 0.137 ms)
```

The results reveal:

- Duration from the initiation of Vim to the effective availability of plugins.
- Elapsed time from when Denops registers the plugin to the complete loading of the plugin script (`load`).
- Time passed from the full loading of the plugin script to the complete initialization of the plugin (`init`).
- Time taken by Vim from loading Denops to rendering Denops fully operational.

> [!NOTE]
> The `load` value may be `0.000 ms` on denops.vim versions that do not yet support the `DenopsPluginRegister` autocmd.
> Upgrading denops.vim itself will resolve this issue.

## License

The code follows MIT license written in [LICENSE](./LICENSE). Contributors need
to agree that any modifications sent in this repository follow the license.
