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
   We're going to use our [letters.sh](./letters.sh) file to help us generate a list of all the possible two letter combinations and store them in `all_letter_combos.txt`:
   ```bash
   $ bash letters.sh > all_letter_combos.txt
   $ < last_two.txt awk '{print $2]' > existing_letter_combos.txt
   $ comm -23 <(sort all_letter_combos.txt) <(sort existing_letter_combos.txt) | wc -l
   590
   ```
   There are 590 possible two letter combinations that do not appear in our `last_two.txt` list.
