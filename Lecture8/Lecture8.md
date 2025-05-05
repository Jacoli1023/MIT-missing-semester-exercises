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

    Solution:\
    - caret (^): This type specifies a range of versions starting from the patch version, but does not exceed the minor version. This is useful if your system depends on a functionality introduced in "1.2.0", and, according to semantic versioning, any further patch will not change the behavior or interface. This is the default.
    - tilde (~): This allows more room for updates, depending on the versioning that comes after it. If you give the major, minor, and the patch, then it is the same as the caret, but if you only specify the major, then any minor versions can be used as well. Can be useful if your functionality only depends on the base major version, allowing any future updates won't affect the behavior of your system, and it keeps the dependency as up-to-date as possible.
    - wildcard (*): This allows for _any_ version where the wildcard specification is. This is not allowed in some build systems, but can be useful in certain scenarios where you're certain that any version where the wildcard is placed will work.
    - comparison (>, <, =): This only allows an exact match (for =) or a range of matches, in the scenario your system is only compatible within this range. For example, if a new minor version is released, but it is buggy or has security flaws, you can allow any versions up to that minor to be used.
    - multiple (,): Can be used with the previous examples, specifically the comparison specification, to allow for specifying exactly which versions or range of versions. If using the comparison, for example, you call allow any version from 1.2.3 up to 1.2.7, but not 1.2.8. Can be useful if you wanted to isolate your system from a potentially buggy dependency.

    ---
 3. **Git can act as a simple CI system all by itself. In `.git/hooks`
    inside any git repository, you will find (currently inactive) files
    that are run as scripts when a particular action happens. Write a
    [`pre-commit`](https://git-scm.com/docs/githooks#_pre_commit) hook
    that runs `make paper.pdf` and refuses the commit if the `make`
    command fails. This should prevent any commit from having an
    unbuildable version of the paper.**

    Solution:\
    ```bash
    #!/bin/sh

    if ! make paper.pdf ; then
        echo "Make paper.pdf failed, aborting commit"
        exit 1
    fi
    ```

    ---
 4. **Set up a simple auto-published page using [GitHub
    Pages](https://pages.github.com/).
    Add a [GitHub Action](https://github.com/features/actions) to the
    repository to run `shellcheck` on any shell files in that
    repository (here is [one way to do
    it](https://github.com/marketplace/actions/shellcheck)). Check that
    it works!**

    Solution:\
    Following the [quickstart guide](https://docs.github.com/en/pages) for GitHub pages, I've set up my own page deploying from the main branch of this repository: [here](https://jacoli1023.github.io/MIT-missing-semester-exercises/).

    ShellCheck is pre-installed on Ubuntu runners, so, following the documentation, we can simply create this workflow which will run on our repository every time we push changes or a pull-request is sent:
    ```yaml
    name: "ShellCheck"
    on: [push, pull_request]

    jobs:
    shellcheck:
        name: ShellCheck
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v4
        - name: Run ShellCheck
        run: find . -type f -name "*.sh" -exec shellcheck {} +
    ```

    ---
 5. **[Build your
    own](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/building-actions)
    GitHub action to run [`proselint`](https://github.com/amperser/proselint) or
    [`write-good`](https://github.com/btford/write-good) on all the
    `.md` files in the repository. Enable it in your repository, and
    check that it works by filing a pull request with a typo in it.**

    I get the sense that the easiest way to do this is through the use of Docker containers, and creating another repository to house it. I will come back to this when I have more knowledge on how best to do that.
