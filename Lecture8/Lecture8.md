# Lecture 8: [Metaprogramming](https://missing.csail.mit.edu/2020/metaprogramming/)


 1. **Most makefiles provide a target called `clean`. This isn't intended
    to produce a file called `clean`, but instead to clean up any files
    that can be re-built by make. Think of it as a way to "undo" all of
    the build steps. Implement a `clean` target for the `paper.pdf`
    `Makefile` above. You will have to make the target
    [phony](https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html).
    You may find the [`git
    ls-files`](https://git-scm.com/docs/git-ls-files) subcommand useful.
    A number of other very common make targets are listed
    [here](https://www.gnu.org/software/make/manual/html_node/Standard-Targets.html#Standard-Targets).**

    Solution:\
    [./Makefile](./Makefile):
    ```make
    paper.pdf: paper.tex plot-data.png
        pdflatex paper.tex

    plot-%.png: %.dat plot.py
        ./plot.py -i $*.dat -o $@

    .PHONY: clean
    clean:
        git ls-files -o | xargs rm -f
    ```

    ---
 2. **Take a look at the various ways to specify version requirements for
    dependencies in [Rust's build
    system](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html).
    Most package repositories support similar syntax. For each one
    (caret, tilde, wildcard, comparison, and multiple), try to come up
    with a use-case in which that particular kind of requirement makes
    sense.**
