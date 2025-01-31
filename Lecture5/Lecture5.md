# Lecture 5: [Command-line Environment](https://missing.csail.mit.edu/2020/command-line/)

## Job control

1. **From what we have seen, we can use some `ps aux | grep` commands to get our jobs' pids and then kill them, but there are better ways to do it. Start a `sleep 10000` job in a terminal, background it with `Ctrl-Z` and continue its execution with `bg`. Now use [`pgrep`](https://www.man7.org/linux/man-pages/man1/pgrep.1.html) to find its pid and [`pkill`](http://man7.org/linux/man-pages/man1/pgrep.1.html) to kill it without ever typing the pid itself. (Hint: use the `-af` flags).**

Solution:\
In this simple case, it is enough to simply use `pgrep` to filter the processes until you're sure that you've found the certain process you wish to kill, then follow it up with `pkill` and the same pattern you used to find that process in order to kill it, without ever needing to type the pid:
```bash
$ sleep 10000 &
$ pgrep -af sleep
10399 sleep 10000
$ pkill -ef sleep
sleep killed (pid 10399)
[1]+  Terminated           sleep 10000
```

---
1. **Say you don't want to start a process until another completes. How would you go about it? In this exercise, our limiting process will always be `sleep 60 &`.
One way to achieve this is to use the [`wait`](https://www.man7.org/linux/man-pages/man1/wait.1p.html) command. Try launching the sleep command and having an `ls` wait until the background process finishes.**

Solution:
```bash
wait $(pgrep sleep) && ls
```

    **However, this strategy will fail if we start in a different bash session, since `wait` only works for child processes. One feature we did not discuss in the notes is that the `kill` command's exit status will be zero on success and nonzero otherwise. `kill -0` does not send a signal but will give a nonzero exit status if the process does not exist.
    Write a bash function called `pidwait` that takes a pid and waits until the given process completes. You should use `sleep` to avoid wasting CPU unnecessarily.**

    Solution:\
    ```bash
    pidwait()
    {
        while kill -0 $1 2>/dev/null
        do
                sleep 1
        done
        ls
    }
    ```

    I have this stored in my [`pidwait.sh`](./pidwait.sh) file, and then I `source` the file to allow me to use the function.

    Almost functionally equivalent to the `wait` command followed by an `ls`, however the `pidwait` function can be utilized for any process, even those that have been started in a different bash session.

    `kill -0`, as explained above, does not send a signal, rather it checks if the process has the ability to _be killed_. In other words, it can be used to check if a process exists, and as such we can use its exit status to determine when to begin our next command (in this case, we're just doing a simple `ls` command).

    ---
## Terminal multiplexer

1. **Follow this `tmux` [tutorial](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/) and then learn how to do some basic customizations following [these steps](https://www.hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/).**

Solution:\
I have been using `tmux` to help streamline the creation of this exercise solutions repo, and have my `.tmux.conf` uploaded to my public [dotfiles](https://github.com/Jacoli1023/dotfiles) repo.

I love configuring things to fit my needs, so undoubtedly I will continue to tweak and modify my config file as time passes. An action I may take sooner rather than later is to have `tmux` start up every time I open the terminal, rather than having to explicitly call `tmux` or attach to a session every time.

---
## Aliases

1. **Create an alias `dc` that resolves to `cd` for when you type it wrongly.**

Solution:
```bash
alias dc=cd
```

---
1.  **Run `history | awk '{$1="";print substr($0,2)}' | sort | uniq -c | sort -n | tail -n 10`  to get your top 10 most used commands and consider writing shorter aliases for them. Note: this works for Bash; if you're using ZSH, use `history 1` instead of just `history`.**

Solution:\
Some of my most used commands involve `git` commands and variations of the `ls` command, as well as the `clear` command. I've already been using some aliases for the `ls` command (shown in my [dotfiles](https://github.com/Jacoli1023/dotfiles) repo), as well as some aliases for git in its respective config file. Though this does give me some interesting ideas for more aliases.

---
## Dotfiles

All of these exercises have been solved and published to my [dotfiles](https://github.com/Jacoli1023/dotfiles) repo (geez I've been linking that a lot). To test migration, I downloaded [Ubuntu Server 24.10](https://ubuntu.com/download/server) on a [VirtualBox](https://www.virtualbox.org/) virtual machine.

My installation method for my dotfiles is as simple as cloning my dotfiles GitHub repo, and using [GNU Stow](https://www.gnu.org/software/stow/) to form symlinks on the new system.

---
## Remote Machines

This section was a little tough for me to understand and execute. I could not tell if I was having some troubles because of virtual machine installation or if I just was not executing the commands properly. For now, I will skip this section and will come back for another go after I finish the rest of the course's exercises.

**Install a Linux virtual machine (or use an already existing one) for this exercise. If you are not familiar with virtual machines check out [this](https://hibbard.eu/install-ubuntu-virtual-box/) tutorial for installing one.**

1. **Go to `~/.ssh/` and check if you have a pair of SSH keys there. If not, generate them with `ssh-keygen -o -a 100 -t ed25519`. It is recommended that you use a password and use `ssh-agent` , more info [here](https://www.ssh.com/ssh/agent).**

Solution:\

---
1. **Edit `.ssh/config` to have an entry as follows**

    ```bash
    Host vm
        User username_goes_here
        HostName ip_goes_here
        IdentityFile ~/.ssh/id_ed25519
        LocalForward 9999 localhost:8888
    ```

    Solution:\

    ---
1. **Use `ssh-copy-id vm` to copy your ssh key to the server.**

Solution:\

---
1. **Start a webserver in your VM by executing `python -m http.server 8888`. Access the VM webserver by navigating to `http://localhost:9999` in your machine.**

Solution:\

---
1. **Edit your SSH server config by doing  `sudo vim /etc/ssh/sshd_config` and disable password authentication by editing the value of `PasswordAuthentication`. Disable root login by editing the value of `PermitRootLogin`. Restart the `ssh` service with `sudo service sshd restart`. Try sshing in again.**

Solution:\

---
1. **(Challenge) Install [`mosh`](https://mosh.org/) in the VM and establish a connection. Then disconnect the network adapter of the server/VM. Can mosh properly recover from it?**

Solution:\

---
1. **(Challenge) Look into what the `-N` and `-f` flags do in `ssh` and figure out a command to achieve background port forwarding.**

Solution:\
