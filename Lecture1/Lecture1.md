# Lecture 1: [Course overview + the shell](https://missing.csail.mit.edu/2020/course-shell/)

 1. **For this course, you need to be using a Unix shell like Bash or ZSH. If you
    are on Linux or macOS, you don't have to do anything special. If you are on
    Windows, you need to make sure you are not running cmd.exe or PowerShell;
    you can use [Windows Subsystem for
    Linux](https://docs.microsoft.com/en-us/windows/wsl/) or a Linux virtual
    machine to use Unix-style command-line tools. To make sure you're running
    an appropriate shell, you can try the command `echo $SHELL`. If it says
    something like `/bin/bash` or `/usr/bin/zsh`, that means you're running the
    right program.**

    ```bash
    $ echo $SHELL
    /bin/bash
    ```

    ---
 1. **Create a new directory called `missing` under `/tmp`.**

    ```bash
    mkdir /tmp/missing
    ```

    ---
 1. **Look up the `touch` program. The `man` program is your friend.**

    ```bash
    man touch
    ```

    ---
 1. **Use `touch` to create a new file called `semester` in `missing`.**

    ```bash
    touch /tmp/missing/semester
    ```

    ---
 1. **Write the following into that file, one line at a time:**
    ```
    #!/bin/sh
    curl --head --silent https://missing.csail.mit.edu
    ```
    **The first line might be tricky to get working. It's helpful to know that
    `#` starts a comment in Bash, and `!` has a special meaning even within
    double-quoted (`"`) strings. Bash treats single-quoted strings (`'`)
    differently: they will do the trick in this case. See the Bash
    [quoting](https://www.gnu.org/software/bash/manual/html_node/Quoting.html)
    manual page for more information.**

    ```bash
    $ echo '#!/bin/sh' > /tmp/missing/semester
    $ echo 'curl --head --silent https://missing.csail.mit.edu' >> /tmp/missing/semester
    ```

    ---
 1. **Try to execute the file, i.e. type the path to the script (`./semester`)
    into your shell and press enter. Understand why it doesn't work by
    consulting the output of `ls` (hint: look at the permission bits of the
    file).**

    ```bash
    $ ./semester
    -bash: ./semester: Permission denied
    ```

    Execution fails because we do not have execution privileges. If we type `ls -l` in the shell, we see that the semester file has the following permission bits set: `-rw-rw-r--`. Thus we, as the owner of the file, can only read from and write to the file, not execute.

    ---
 1. **Run the command by explicitly starting the `sh` interpreter, and giving it
    the file `semester` as the first argument, i.e. `sh semester`. Why does
    this work, while `./semester` didn't?**

    This works because sh is a POSIX-compliant command interpreter. Rather than trying to execute the file, `sh` simply interprets the file given as an argument - in this case our `semester` file.

    ---
 1. **Look up the `chmod` program (e.g. use `man chmod`).**

    ```bash
    man chmod
    ```

    ---
 1. **Use `chmod` to make it possible to run the command `./semester` rather than
    having to type `sh semester`. How does your shell know that the file is
    supposed to be interpreted using `sh`? See this page on the
    [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) line for more
    information.**

    ```bash
    chmod u+x ./semester
    ```

    The shell knows to interpret the file using `sh` because of the shebang we included at the top of the file. Shebangs tell bash which interpreter to use.

    ---
 1. **Use `|` and `>` to write the "last modified" date output by
    `semester` into a file called `last-modified.txt` in your home
    directory.**

    ```bash
    # using regex
    ./semester | grep "last-modified" > ~/last-modified.txt
    ```

    ---
 1. **Write a command that reads out your laptop battery's power level or your
    desktop machine's CPU temperature from `/sys`.**

    ```bash
    $ cat /sys/class/power_supply/BAT1/capacity
    47
    ```
