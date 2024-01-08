# denops-startup-recorder

A [denops][denops] plugin to record startup performance of denops plugins.

[denops]: https://github.com/vim-denops/denops.vim

Call `DenopsStartupRecorderDisplayEvents` to echo the result

```
:DenopsStartupRecorderDisplayEvents
```

The results reveal:

- Event timing from the plugin load
- Time passed from the full loading of the plugin script to the complete initialization of the plugin (`init`).<br>`DenopsPluginPost:* - DenopsPluginPre:*`

## License

The code follows MIT license written in [LICENSE](./LICENSE). Contributors need
to agree that any modifications sent in this repository follow the license.
