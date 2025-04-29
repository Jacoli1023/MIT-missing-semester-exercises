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

    From the data, we see that insertion sort is slower than quicksort, with runtimes of 0.137s and 0.101s, respectively. The majority of the time spent in insertion sort was in the while loop, whereas the majority of the time spent in quicksort were the assignments of the `left` and `right` variables. This is likely due to the fact these lines have assignment, iteration, and a conditional all packaged into a single line.

    - The memory profiler did not seem to work for me, as after decorating with `@profile` tags and importing the profile module, it would then get stuck in some sort of infinite loop. However, I would guess that the quicksort uses more memory than the insertion sort, due to the amount of recursive calls it makes, thus demanding more of the stack than insertion sort.

    - Now for the challenge of using `perf` to look at cycle counts and cache hits and misses of each alogirthm. For this, I will modify the `sorts.py` program to only run one algorithm at a time, and then record the stats for those. First, we'll do quicksort:

    ```bash
    $ sudo perf stat -e cpu-cycles,cache-misses,cache-references python sorts.py
    
    Performance counter stats for 'python sorts.py':

        75,791,961      cpu_atom/cpu-cycles/                                                    (16.16%)
       113,268,526      cpu_core/cpu-cycles/                                                    (83.84%)
           630,818      cpu_atom/cache-misses/           #   65.02% of all cache refs           (16.16%)
            98,904      cpu_core/cache-misses/           #   13.37% of all cache refs           (83.84%)
           970,240      cpu_atom/cache-references/                                              (16.16%)
           739,760      cpu_core/cache-references/                                              (83.84%)

       0.058614041 seconds time elapsed

       0.052757000 seconds user
       0.005972000 seconds sys
    ```

    Then, quicksort inplace:

    ```bash
    $ sudo perf stat -e cpu-cycles,cache-misses,cache-references python sorts.py

    Performance counter stats for 'python sorts.py':

        62,918,465      cpu_atom/cpu-cycles/                                                    (16.33%)
        94,244,721      cpu_core/cpu-cycles/                                                    (83.67%)
           538,798      cpu_atom/cache-misses/           #   73.44% of all cache refs           (16.33%)
           112,033      cpu_core/cache-misses/           #   14.56% of all cache refs           (83.67%)
           733,624      cpu_atom/cache-references/                                              (16.33%)
           769,571      cpu_core/cache-references/                                              (83.67%)

       0.052613109 seconds time elapsed

       0.041142000 seconds user
       0.011754000 seconds sys
    ```

    And finally, insertion sort:

    ```bash
    $ sudo perf stat -e cpu-cycles,cache-misses,cache-references python sorts.py

    Performance counter stats for 'python sorts.py':

        66,712,034      cpu_atom/cpu-cycles/                                                    (6.78%)
        90,556,650      cpu_core/cpu-cycles/                                                    (93.22%)
           760,342      cpu_atom/cache-misses/           #   76.94% of all cache refs           (6.78%)
           117,254      cpu_core/cache-misses/           #   18.31% of all cache refs           (93.22%)
           988,175      cpu_atom/cache-references/                                              (6.78%)
           640,328      cpu_core/cache-references/                                              (93.22%)

       0.049202230 seconds time elapsed

       0.043021000 seconds user
       0.006145000 seconds sys
    ```

    To calculate cache hits, we need to subtract the cache misses from cache references. There was no way to explicitly ask for a cache hit as a PMU event for `perf stat`.

    ---
1. **Put the code into a file and make it executable. Install prerequisites: [`pycallgraph`](https://lewiscowles1986.github.io/py-call-graph/) and [`graphviz`](http://graphviz.org/). (If you can run `dot`, you already have GraphViz.) Run the code as is with `pycallgraph graphviz -- ./fib.py` and check the `pycallgraph.png` file. How many times is `fib0` called?. We can do better than that by memoizing the functions. Uncomment the commented lines and regenerate the images. How many times are we calling each `fibN` function now?**

    Solution:
    After running the command, the [`pycallgraph.png`](./pycallgraph.png) file is created, which shows that the `fib0` function is called 21 times.

    Memoizing functions means to store the return value of a function when passed in the same arguments, which cuts down on computation and logic as we can simply return the previously calculated value. This is what the lines 11-13 do, and when we rerun the program, we can see the memoization take effect, as this time we only call the `fib0`, or really any `fibN` function, once.

    ---
1. **A common issue is that a port you want to listen on is already taken by another process. Let's learn how to discover that process pid. First execute `python -m http.server 4444` to start a minimal web server listening on port `4444`. On a separate terminal run `lsof | grep LISTEN` to print all listening processes and ports. Find that process pid and terminate it by running `kill <PID>`.**

    Solution:\
    ```bash
    $ lsof | grep LISTEN | grep 4444
    
    ... excluded stdout of command
    
    $ kill 89534
    ```

    ---
1. **Limiting a process's resources can be another handy tool in your toolbox.**
**Try running `stress -c 3` and visualize the CPU consumption with `htop`. Now, execute `taskset --cpu-list 0,2 stress -c 3` and visualize it. Is `stress` taking three CPUs? Why not? Read [`man taskset`](https://www.man7.org/linux/man-pages/man1/taskset.1.html).**
**Challenge: achieve the same using [`cgroups`](https://www.man7.org/linux/man-pages/man7/cgroups.7.html). Try limiting the memory consumption of `stress -m`.**

    Solution:\
    After running the `stress` command, in another tmux pane I had `htop` running, which showed 3 of my CPUs being hogged at once, often switching between which CPU was being hogged.

    Then, after running the `taskset` command, followed by the `stress` command, this time I only saw two of my CPUs being hogged, specifically core 0 and 2. This is because the `taskset` command sets a the CPU's affinity to a certain process. When we execute the above command, it sets cores' 0 and 2 affinity to the stress command, and thus they are the only ones that run that command.
    
    - Now for the challenge of using `cgroups`. I will be using `cgroups v2`, where all mounted controllers reside in a single unified heirarchy. These are the following steps I took in order to limit the memory consumption of the `stress` command:

    ```bash
    $ sudo mkdir /sys/fs/cgroup/cgroup_test
    $ cd /sys/fs/cgroup/cgroup_test
    $ echo "+memory" | sudo tee ./cgroup.subtree_control
    $ echo "200M" | sudo tee ./memory.high
    ```

    This sets up the `cgroup` to be ready for memory control, and designates the high limit of its processes to be 200M. Next, in another terminal, we can run the `stress -m 3` command, view its PID and then use its PID to move it into the `cgroup.procs` interface file. We can then use `htop` to watch its memory consumption be throttled.

    ---
1. **(Advanced) The command `curl ipinfo.io` performs a HTTP request and fetches information about your public IP. Open [Wireshark](https://www.wireshark.org/) and try to sniff the request and reply packets that `curl` sent and received. (Hint: Use the `http` filter to just watch HTTP packets).**

    Skipped.
