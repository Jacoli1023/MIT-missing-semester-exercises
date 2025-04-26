# Lecture 7: [Debugging and Profiling](https://missing.csail.mit.edu/2020/debugging-profiling/)

## Debugging

1. **Use `journalctl` on Linux or `log show` on macOS to get the super user accesses and commands in the last day.**
**If there aren't any you can execute some harmless commands such as `sudo ls` and check again.**

    Solution:
    ```bash
    $ journalctl -S yeseterday | grep sudo
    ```

    ---
1. **Do [this](https://github.com/spiside/pdb-tutorial) hands on `pdb` tutorial to familiarize yourself with the commands. For a more in depth tutorial read [this](https://realpython.com/python-debugging-pdb).**

---
1. **Install [`shellcheck`](https://www.shellcheck.net/) and try checking the following script. What is wrong with the code? Fix it. Install a linter plugin in your editor so you can get your warnings automatically.**

   ```bash
   #!/bin/sh
   ## Example: a typical script with several problems
   for f in $(ls *.m3u)
   do
     grep -qi hq.*mp3 $f \
       && echo -e 'Playlist $f contains a HQ file in mp3 format'
   done
   ```

    Solution:
    Running `shellcheck` on the code above, which I've put into the [`buggy_example.sh`](./buggy_example.sh) file, I receive one error and two warnings. The error I receive on line 3 is telling me to use globs instead of iterating directly of ls output.

    The first warning I recieve is on line 5, advising me to double quote the grep pattern so the shell won't try to interpret it. The second warning I receive is on line 6, saying that echo flags are undefined in POSIX sh, so we should fix that to make it POSIX compatible.

    After fixing those issues, our fixed solution looks like [`fixed_example.sh`](./fixed_example.sh).

    ---

1. **(Advanced) Read about [reversible debugging](https://undo.io/resources/reverse-debugging-whitepaper/) and get a simple example working using [`rr`](https://rr-project.org/) or [`RevPDB`](https://morepypy.blogspot.com/2016/07/reverse-debugging-for-python.html).**

---
## Profiling

1. **[Here](/static/files/sorts.py) are some sorting algorithm implementations. Use [`cProfile`](https://docs.python.org/3/library/profile.html) and [`line_profiler`](https://github.com/pyutils/line_profiler) to compare the runtime of insertion sort and quicksort. What is the bottleneck of each algorithm? Use then `memory_profiler` to check the memory consumption, why is insertion sort better? Check now the inplace version of quicksort. Challenge: Use `perf` to look at the cycle counts and cache hits and misses of each algorithm.**

    Solution:
    - First, using cProfile, we can see that insertion sort actually has a shorter cumulative runtime than the quicksorts. This is likely due to the fact that quicksort has a larger overhead from its recursive calls, and the fact that we're operating on a smaller dataset.

    ```bash
    $ python -m cProfile -s cumtime sorts.py | grep -e sorts.py -e cumtime
    ncalls  tottime  percall  cumtime  percall filename:lineno(function)
         1    0.000    0.000    0.261    0.261 sorts.py:1(<module>)
         3    0.020    0.007    0.260    0.087 sorts.py:4(test_sorted)
33914/1000    0.032    0.000    0.035    0.000 sorts.py:23(quicksort)
34178/1000    0.025    0.000    0.029    0.000 sorts.py:32(quicksort_inplace)
      1000    0.012    0.000    0.012    0.000 sorts.py:11(insertionsort)
    ```

    - Next, using line_profiler. We'll have to add the `@profile` tags before the insertion sort and quicksort function definitions.

    ```bash
    $ kernprof -l -v sorts.py
    Total time: 0.137286 s
    File: sorts.py
    Function: insertionsort at line 11

    Line #      Hits         Time  Per Hit   % Time  Line Contents
    ==============================================================
        11                                           @profile
        12                                           def insertionsort(array):
        13                                           
        14     26254       4637.9      0.2      3.4      for i in range(len(array)):
        15     25254       3951.3      0.2      2.9          j = i-1
        16     25254       4654.4      0.2      3.4          v = array[i]
        17    231199      50115.6      0.2     36.5          while j >= 0 and v < array[j]:
        18    205945      37184.6      0.2     27.1              array[j+1] = array[j]
        19    205945      31532.5      0.2     23.0              j -= 1
        20     25254       4798.5      0.2      3.5          array[j+1] = v
        21      1000        411.6      0.4      0.3      return array

    
    Total time: 0.101222 s
    File: sorts.py
    Function: quicksort at line 23

    Line #      Hits         Time  Per Hit   % Time  Line Contents
    ==============================================================
        23                                           @profile
        24                                           def quicksort(array):
        25     33420       9496.4      0.3      9.4      if len(array) <= 1:
        26     17210       4011.4      0.2      4.0          return array
        27     16210       2970.5      0.2      2.9      pivot = array[0]
        28    123504      33547.3      0.3     33.1      left = [i for i in array[1:] if i < pivot]
        29    123504      32987.4      0.3     32.6      right = [i for i in array[1:] if i >= pivot]
        30     16210      18208.7      1.1     18.0      return quicksort(left) + [pivot] + quicksort(right)
    ```

    From the data, we see that insertion sort is slower than quicksort, with runtimes of 0.137s and 0.101s, respectively. The majority of the time spent in insertion sort was in the conditional of the while loop, whereas the majority of the time spent in quicksort was the assignment of the `left` and `right` variables, which makes sense because this line has assignment, iteration, and a conditional all packaged into one line.

    - 
