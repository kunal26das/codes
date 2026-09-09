# Local compatibility patch

This directory contains the unchanged `lib/` sources and MIT license from
[`liquid_glass_renderer` 0.2.0-dev.4](https://pub.dev/packages/liquid_glass_renderer/versions/0.2.0-dev.4).

The upstream package declares four Impeller-only shaders for every platform.
Flutter's web release build attempts to compile them for Skia and fails before
the package can use its existing `FakeGlass` runtime fallback.

Our manifest limits those shader assets to Android, iOS, and macOS. Native
rendering is unchanged; web uses the package's existing frosted-glass fallback.
The manifest also disables publishing and omits upstream development-only
dependencies and screenshot metadata. This requires Flutter 3.44 or later:
[that release's asset loader](https://github.com/flutter/flutter/blob/3.44.0/packages/flutter_tools/lib/src/asset.dart)
honors platform filters on shader entries. Application analysis excludes this
unmodified third-party source; application tests and builds still compile it.

To update: copy the new upstream `lib/` and `LICENSE`, reconcile runtime
dependencies, and retain the shader platform filters until upstream includes an
equivalent fix. Verify the web release build and a native build before removing
this patch.
