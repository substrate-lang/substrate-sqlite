# sqlite

SQLite as a wasm module, with its file layer and API in
[Substrate](https://github.com/substrate-lang/substrate). Programs can use it in
the browser and on the command line.

    substrate test -A        # the tests, one of them in Chromium

The dev shell (`nix develop`) has what building SQLite takes. In it:

    ./build.sh               # sqlite3.wasm, from SQLite's amalgamation
    bench/run.sh             # against SQLite built natively, on speedtest1's SQL

The benchmark uses the substrate repository next to this one.
