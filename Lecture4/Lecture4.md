# Lecture 4: [Data Wrangling](https://missing.csail.mit.edu/2020/data-wrangling/)

1. **Take this [short interactive regex tutorial](https://regexone.com/).**

    ---
2. **Find the number of words (in `/usr/share/dict/words`) that contain at
   least three `a`s and don't have a `'s` ending. What are the three
   most common last two letters of those words? `sed`'s `y` command, or
   the `tr` program, may help you with case insensitivity. How many
   of those two-letter combinations are there? And for a challenge:
   which combinations do not occur?**

   Solution:\
   This exercise problem requires the use of many commands over a subset of data, which pulls from the much larger set of data from `/usr/share/dict/words`. To make this a slightly easier and less intensive process, we're going to put our first subset of data into its own text file, and then use that file to help us solve the rest of the exercise:

   ```bash
   < /usr/share/dict/words tr "[:upper:]" "[:lower:]" | grep -E "([^a]*a){3}.*[^(\'s)]$" > three_a.txt
   ```

   We'll also need to further utilize a smaller subset of data from our `three_a.txt`, which we'll go ahead and put into its own text file as well:

   ```bash
   < three_a.txt sed -E "s/.*([a-z]{2})$/\1/" | sort | uniq -c > last_two.txt
   ```

   We can now divide the exercise into its three individual parts, and use our `three_a.txt` and `last_two.txt` to help us solve them:

   - Find the number of words (in `/usr/share/dict/words`) that contain at
   least three `a`s and don't have a `'s` ending.
   ```bash
   $ < three_a.txt wc -l
   442
   ```

   - What are the three most common last two letters of those words?
   ```bash
   $ < last_two.txt sort -nr | head -n3 | awk '{print $2}'
   an
   al
   ly
   ```

   - How many of those two-letter combinations are there?
   ```bash
   $ < last_two.txt wc -l
   86
   ```

   - And for a challenge: which combinations do not occur?\
   We're going to use our [letters.sh](./q2/letters.sh) file to help us generate a list of all the possible two letter combinations and store them in `all_letter_combos.txt`:
   ```bash
   $ bash letters.sh > all_letter_combos.txt
   $ < last_two.txt awk '{print $2]' > existing_letter_combos.txt
   $ comm -23 <(sort all_letter_combos.txt) <(sort existing_letter_combos.txt) | wc -l
   590
   ```
   There are 590 possible two letter combinations that do not appear in our `last_two.txt` list.

   ---
3. **To do in-place substitution it is quite tempting to do something like
   `sed s/REGEX/SUBSTITUTION/ input.txt > input.txt`. However this is a
   bad idea, why? Is this particular to `sed`? Use `man sed` to find out
   how to accomplish this.**

   Solution:
   To accomplish in-place substitution with `sed`, we must use the `-i` flag. The manual for `sed` advises us to make a backup, and that's because substituting in-place can have some unforeseen consequences, especially dealing with regex's. If a mistake is made in the regex, we may end up corrupting the file without an easy way to recover the previous state.

   ---
4. **Find your average, median, and max system boot time over the last ten
   boots. Use `journalctl` on Linux and `log show` on macOS, and look
   for log timestamps near the beginning and end of each boot. On Linux,
   they may look something like:**
   ```
   Logs begin at ...
   ```
   **and**
   ```
   systemd[577]: Startup finished in ...
   ```

   Solution:\
   Working with `journalctl` takes a long time to process, and when dealing with specific logs, it is much easier to `grep` through the logs for the certain data we're looking for, storing those logs into a text file, and then working with and manipulating those logs through the text file.

   We can do this first with this command:
   ```bash
   journalctl | grep 'systemd\[1\]: Startup finished in' > bootlogs.txt
   ```

   With that out of the way, we can now look through our last ten boots and begin performing some simple statistical analysis:
   ```bash
   $ < bootlogs.txt sed -E 's/.*= (.+)s\.$/\1/' | tail -n10 | st --mean --median --max
   median  max     mean
   36.2785 36.577  36.2164
   ```
   Note: I am using [st](https://github.com/nferraz/st) to perform my statistical analysis.

   ---
5. **Look for boot messages that are _not_ shared between your past three
   reboots (see `journalctl`'s `-b` flag). Break this task down into
   multiple steps. First, find a way to get just the logs from the past
   three boots. There may be an applicable flag on the tool you use to
   extract the boot logs, or you can use `sed '0,/STRING/d'` to remove
   all lines previous to one that matches `STRING`. Next, remove any
   parts of the line that _always_ varies (like the timestamp). Then,
   de-duplicate the input lines and keep a count of each one (`uniq` is
   your friend). And finally, eliminate any line whose count is 3 (since
   it _was_ shared among all the boots).**

   ```bash
   journalctl -b -3 | sed -E 's/.*laptop\s*(.*)$/\1/' | sort | uniq -c | sort -n | awk '$1 < 3 { print }'
    ```

   ---
6. **Find an online data set like [this
   one](https://stats.wikimedia.org/EN/TablesWikipediaZZ.htm), [this
   one](https://ucr.fbi.gov/crime-in-the-u.s/2016/crime-in-the-u.s.-2016/topic-pages/tables/table-1),
   or maybe one [from
   here](https://www.springboard.com/blog/data-science/free-public-data-sets-data-science-project/).
   Fetch it using `curl` and extract out just two columns of numerical
   data. If you're fetching HTML data,
   [`pup`](https://github.com/EricChiang/pup) might be helpful. For JSON
   data, try [`jq`](https://stedolan.github.io/jq/). Find the min and
   max of one column in a single command, and the difference of the sum
   of each column in another.**

   Solution:\
   I will be using [this](https://stats.wikimedia.org/EN/TablesWikipediaZZ.htm) data set, and will be extracting the "total Wikipedians" and the "new Wikipedians" columns:
   ```bash
   curl -s https://stats.wikimedia.org/EN/TablesWikipediaZZ.htm | awk -F "[><]" '/^<tr>.*<\/tr>$/ { printf "%-10s $s\n", $9, $13 }' | awk 'NR >= 6 && NR <=220 { print }' > wikistats.txt
   ```

   - The min and max of the second column (new Wikipedians):
   ```bash
   $ < wikistats.txt awk '{ print $2 }' | st --min --max
   min     max
   7       24875
   ```
   - The sum of the second column (new Wikipedians):
   ```bash
   $ < wikistats.txt awk '{ print $2 }' | paste -sd+ | bc
   2654772
   ```
