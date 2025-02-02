# Lecture 6: [Version Control (Git)](https://missing.csail.mit.edu/2020/version-control/)

1. **If you don't have any past experience with Git, either try reading the first
   couple chapters of [Pro Git](https://git-scm.com/book/en/v2) or go through a
   tutorial like [Learn Git Branching](https://learngitbranching.js.org/). As
   you're working through it, relate Git commands to the data model.**

   ---
1. **Clone the [repository for the
class website](https://github.com/missing-semester/missing-semester).**

   Solution:
   ```bash
   git clone https://github.com/missing-semester/missing-semester ~/missing_semester/
   ```

    1. **Explore the version history by visualizing it as a graph.**

       Solution:
       ```bash
       cd missing_semester
       git log --graph
       ```
    1. **Who was the last person to modify `README.md`? (Hint: use `git log` with
       an argument).**

       Solution:
       ```bash
       $ git log README.md | head -n2 | tail -n1
       Author: Anish Athalye <me@anishathalye.com>
       ```

    1. **What was the commit message associated with the last modification to the
       `collections:` line of `_config.yml`? (Hint: use `git blame` and `git
       show`).**

       Solution:
       ```bash
       $ git blame _config.yml | grep collections: | awk '{print $1}' | xargs git show --oneline 2>/dev/null | head -n1 | sed -E 's/^\s*([a-zA-Z0-9]+) (.*)/\2/'
       Redo lectures as a collection
       ```

   ---
1. **One common mistake when learning Git is to commit large files that should
   not be managed by Git or adding sensitive information. Try adding a file to
   a repository, making some commits and then deleting that file from history
   (you may want to look at
   [this](https://help.github.com/articles/removing-sensitive-data-from-a-repository/)).**

   Solution:\
   In this solution, I'm going to use the example in which we accidentally upload
   a text file which contains sensitive information (in this case passwords) to
   this github repo. I'll have two example text files: the
   [`orig_passwords.txt`](./orig_passwords.txt) is the preserved text file with the
   original, "sensitive" information, and the [`passwords.txt`](./passwords.txt) file
   is what the file looks like after I execute the `git filter-repo` command (found
   [here](https://github.com/newren/git-filter-repo)).

   ```bash
   $ git clone https://github.com/Jacoli1023/MIT-missing-semester-exercises.git
   $ cd MIT-missing-semester-exercises
   $ git filter-repo --sensitive-data-removal --replace-text ./passwords.txt
   ```

   Caution is required when attempting to rewrite history. Such is this case in this example; when testing out this code I accidentally created a commit history that was unrelated to my main branch. Luckily merging the two wasn't too difficult, but this should only happen when absolutely necessary, as this is one of the few scenarios in git where information could be lost.

   Upon going into `passwords.txt`, we now see all of its content has been replaced with `***REMOVED***`. This also replaces the text of any files which contain `passwords.txt` in their file names (such as backup files with the added `.bak` suffix).

   ---
1. **Clone some repository from GitHub, and modify one of its existing files.
   What happens when you do `git stash`? What do you see when running `git log
   --all --oneline`? Run `git stash pop` to undo what you did with `git stash`.
   In what scenario might this be useful?**

   Solution:\
   `git stash` - Stash the changes in a dirty working directory away\
   `git stash pop` - Remove a single stashed state from the stash list and apply it on top of the current working tree state

   When we look at `git log`, what we see is is a hash id followed by `(refs/stash) WIP on master:` and another hash id and commit message of the last working commit (usually where the `HEAD` pointer is at). Thus `git stash` can be useful in the scenario where we've made some changes to a file or directory, but aren't quite ready to commit those changes. Thus we can `git stash` them for a bit while we work on something else (i.e. more demanding bug fixes), and then when we're ready we can `git stash pop` to get our work back.

   ---
1. **Like many command line tools, Git provides a configuration file (or dotfile)
   called `~/.gitconfig`. Create an alias in `~/.gitconfig` so that when you
   run `git graph`, you get the output of `git log --all --graph --decorate
   --oneline`. You can do this by directly
   [editing](https://git-scm.com/docs/git-config#Documentation/git-config.txt-alias)
   the `~/.gitconfig` file, or you can use the `git config` command to add the
   alias. Information about git aliases can be found
   [here](https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases).**

   Solution:
   ```bash
   git config --global alias.graph 'log --all --graph --decorate --oneline'
   ```

   ---
1. **You can define global ignore patterns in `~/.gitignore_global` after running
   `git config --global core.excludesfile ~/.gitignore_global`. Do this, and
   set up your global gitignore file to ignore OS-specific or editor-specific
   temporary files, like `.DS_Store`.**

   Solution:\
   One type of file that would be pretty helpful to ignore would be the `.swp` files
   created by tmux when working in the same directory.

   ---
1. **Fork the [repository for the class
   website](https://github.com/missing-semester/missing-semester), find a typo
   or some other improvement you can make, and submit a pull request on GitHub
   (you may want to look at [this](https://github.com/firstcontributions/first-contributions)).
   Please only submit PRs that are useful (don't spam us, please!). If you
   can't find an improvement to make, you can skip this exercise.**

   Solution:\
   If I find a mistake or a typo further in the course, I can submit a pull request and edit this to include my specific pull request.
