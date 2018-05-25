# Module simple-bitmap

The `simple-bitmap` module is an experiment, not only in learning the
[Racket](https://racket-lang.org/) language, but also in building complete
packages in an idiomatic manner (following
  [a Style Guide](https://docs.racket-lang.org/style/index.html)).

## Bitmap API

TBD

**Example:**

```racket
(define bm (make-bitmap 7 8))
(for ([row (range 4)])
     (pixel-set! bm row 3 1))
(for ([col (range 4)])
     (pixel-set! bm 3 col 1))
(bitmap-print bm)
(bitmap-fill! bm 2 2 9)
(bitmap-print bm)

```

## Module-As-Template

This is a first attempt at a pedagogical package with full
[RackUnit](https://docs.racket-lang.org/rackunit/) tests and
[Scribble](https://docs.racket-lang.org/scribble/index.html) documentation.
Initially created with [raco](https://docs.racket-lang.org/raco/index.html)
there were some complexities in getting the command line build tools working
correctly.

Running the tests was reasonably easy, but to use `raco` from the collection
root required adding `--modules .` as an argument.

```bash
$ raco test --modules .
raco test: "./info.rkt"
raco test: "./main.rkt"
raco test: "./private/simple-bitmap.rkt"
raco test: "./private/test-simple-bitmap.rkt"
8 tests passed
```

For the documentation there were a few more issues, the `raco` command line
was considerably more complex, but this was relatively easy to figure out.
The one element that should be changed here is the output folder specified by
`--dest` as it should go in a build location not a source folder.

```bash
$ raco scribble --html +m --redirect-main http://docs.racket-lang.org/ \
       --dest scribblings/ scribblings/simple-bitmap.scrbl
 [Output to scribblings/simple-bitmap.html]
 ```
