## [Making Data, the DataMade Way](https://github.com/datamade/data-making-guidelines/blob/master/README.md)
1. **Make & Makefile Overview**
2. [ETL Styleguide](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md)

# Make & Makefile Overview

To achieve a reproducible data workflow, DataMade uses [GNU's Make](http://en.wikipedia.org/wiki/Make_%28software%29). 

Make is a *build automation tool* – it helps build files from source code by keeping track of dependencies and executing shell commands. Out in the wider world, you're most likely to see people using Make to compile software. But it has a bunch of nice properties that make it useful for processing all kinds of data, too.

Make runs in the command line, and Makefiles are written primarily in the bash scripting language. To understand this guide, you should be comfortable writing basic scripts in bash and editing files in the Unix filesystem. If you feel shaky on the command line (or just want to brush up), we recommend you start with Ryan Chadwick's [Linux](http://ryanstutorials.net/linuxtutorial/) and [bash scripting](http://ryanstutorials.net/bash-scripting-tutorial/) tutorials and come back when you're ready.

On this page we discuss our reasons for using Make, and provide a brief introduction to the way it works.  

## Contents

1. [Why Use Make/Makefiles?](#1-why-use-makemakefiles)
2. [Makefile 101](#2-makefile-101)
3. [Makefile 201 - Some Fancy Things Built Into Make](#3-makefile-201---some-fancy-things-built-into-make)


### 1. Why Use Make/Makefiles?

As a build automation tool, Make generates files (called *targets*), each of which can depend upon the existence of other files (called *dependencies*). Targets, dependencies, and instructions for how to build them (called *recipes*) are defined in a special file called a Makefile. 

The nice thing about Makefiles is that once you specify the ways in which your files depend on one another (a "dependency graph"), Make will look at the files you have and do the work of figuring out the individual steps required to build the output that you want. If you're trying to make a target and you already have some of its dependencies, Make will skip the steps required to produce those dependencies; if you're missing a bunch of dependencies, on the other hand, it will figure out the fastest way of producing them. This property of Make means that you can change a rule or a dependency and rebuild your output without having to rerun every single step along the way.

In short, **Make is a particularly nifty tool for data processing because**:
- Make allows you to produce your final data with a single command
- Writing a Makefile forces you to make your data processing steps explicit
- Make is smart about only building what's necessary, because it keeps track of dependencies
- Make is efficient, and gives you parallel processing for nearly free
- If you have a Mac or run Linux, Make is already on your computer! (If you run Windows, I'm sorry - you may have to [install it manually.](http://gnuwin32.sourceforge.net/packages/make.htm))

For a more eloquent argument in favor of using Make for data processing, see ["Why Use Make" by Mike Bostock](http://bost.ocks.org/mike/make/).

### 2. Makefile 101

#### Rules

The basic building block of a Makefile is a *"rule"*: a small block of code that executes one step of your data-making process. Each "rule" consists of (1) a *target*, (2) the target's *dependencies*, and the target's *recipe* (the commands for creating the target).

**The general structure of a single Make "rule" looks like this:**
```
<target>: <dependencies>
[tab] <recipe>
```
*A note about __tabs__: one big difference between bash scripting and Makefiles is that in Make, recipes absolutely must be indented with a tab (and not spaces). This can be a common source of strange errors.*

The **target** is what you want the rule to generate. Up until this point we've assumed that the target will be a file (and most often it is), but one of Make's brilliant properties is that the target doesn't have to be a *literal filename* – it can also be a [phony target](https://github.com/datamade/data-making-guidelines#phony-targets) or a [variable](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md#2-variables), two special kinds of targets. Phony targets and variables are very useful for writing Makefiles, but you don't have to understand what they do yet! The most important concept to understand is that a target is the identifying label for a rule that allows the user to reference it.

A rule's **dependencies** are everything that needs to exist in order to make the target. Like targets, Make expects dependencies to be files, but they can also be phony targets or variables. Unlike targets, dependencies are *optional* - if your target has no dependencies, Make will go ahead and run whatever code is contained in the recipe, whether or not you have all of the things it needs to run. Dependencies are useful for making sure that all of your files are ready to generate your target.   

A **recipe** lists the commands that Make needs to run to generate the target. Any command you can run on the command line is fair game for recipes, and any recipe should be able to be run on its own in your shell. This means you're free to use command line utilities, edit the filesystem, and run scripts in your recipe. Just remember: any command line utility you use that isn't built into the bash language or included in the repo will need to be clearly identified (ideally with installation instructions) in your README, or else users with different machines might not be able to run your Makefile.

In the end, a **Makefile** is mostly a collection of rules for generating targets, as well as the dependencies for those targets. In this way, a Makefile is a lot like any old program you might write: it defines functions (rules) for running code (bash commands) to modify files (perform ETL). One of the biggest differences between a Makefile and a standard program, however, is that compared to most programs, writing a Makefile requires thinking *backwards*.  

#### Thinking backwards

What does it mean to think backwards? Well, consider the simplest way of thinking about editing data: as a series of discrete steps. You start with a source file, then you run it through a script, and then you redirect the output to a new file. We might describe this way of conceptualizing code as "thinking *forward*", since you start at the input and step "forward" toward the output. 

When making data, however, you can also also think *backwards* - in terms of the outputs that you want to produce, and the files that those outputs are derived from. Thinking backwards is a more powerful way of expressing a data workflow, since dependencies aren't always linear, and sometimes your dependencies change (when you receive an updated source file, for example).

To illustrate this kind of thinking, imagine that you want to produce a [table of test scores for every school in Illinois](https://github.com/datamade/school-report-cards). In this case, generating the table itself is the last step, step 3, where you join a table containing a list of every school in Illinois and its corresponding ID number to a table containing ID numbers and test scores; step 2 is cleaning raw data sources to edit and format all of the columns that you need; and step 1 is scraping the raw data from the web. 

Thinking backwards (and in pseudocode, with the fake commands `join`, `edit`, and `format`), we might represent this workflow something like this:

```bash
# step 3 - build the output
final_table: clean_schools.csv clean_scores.csv
    join clean_schools.csv clean_scores.csv > final_table

# step 2b - clean the raw data
clean_schools.csv: raw_schools.csv
    edit raw_schools.csv | format > clean_schools.csv
    
# step 2a - clean the raw data
clean_scores.csv: raw_scores.csv
    edit raw_scores.csv | format > clean_scores.csv

# step 1b - scrape the web
raw_schools.csv: 
    wget -O raw_schools.csv https://url.for/raw/schools
    
# step 1a - scrape the web
raw_scores.csv:
    wget -O raw_scores.csv https://url.for/raw/scores

```

Even though you "thought backwards" to produce this table, when you're done writing your Makefile, you'll typically move things into a more standard "forward" order to help your users read your work.

This kind of "backwards" thinking can be a tricky concept to get your head around. Let's take a look at how Make runs to see what it means in practice.

#### Running Make

Every time you run the `make` command, you tell it which target file you want it to build (with the syntax `make <target>`). Extending the example above, you would run the following command to generate your table:

```
make final_table
```

Now, Make will look for a Makefile in your working directory, find the target that you're after (`final_table`), and check to see if its dependencies (`clean_schools.csv` and `clean_scores.csv`) exist and are up to date. If a dependency (say, `clean_schools.csv`) is too old or doesn't exist, Make will step back, treat that dependency as a new "target", and check the dependencies *of that dependency* (in this case, `raw_schools.csv`). In this way, Make thinks both *backwards* and *recursively*, generating a dependency tree starting with your output and extending all the way back to the most basic missing dependency.

### 3. Makefile 201 - Some Fancy Things Built Into Make

By now, you should have a decent understanding of what Make is for and what a Makefile typically looks like. If you still feel confused, take a look at our [annotated examples of Make rules](https://datamade.github.io/data-making-guidelines/) or browse our [suggested reading](https://github.com/datamade/data-making-guidelines#further-reading).

In this section we describe some of the most common tools DataMade uses that come built-in with Make. None of these tools are required for a Makefile to run, but they'll help keep your work clean and concise. What follows is nowhere near complete documentation of Make functionality - for that, you should [read the docs](https://www.gnu.org/software/make/manual/make.html), of course.

#### Phony Targets

By default, Make assumes that targets are files - and usually they are. However, sometimes it is useful to define rules that a user can run that do not produce a single file, but instead perform some set of commands. For example, you might want to make all of the targets in the Makefile at once, or you might want to remove everything you've created from your directory - in both of these cases Make needs to do a bunch of things to a bunch of files, rather than run commands to produce one single file. In cases like these we can use "phony targets": targets that aren't defined by one specific file, but that instead act more like function names, encapsulating a set of useful commands. 

To define phony targets, you must explicitly tell Make that they are not associated with files, like so:

```
.PHONY: all clean
```

Now, Make will understand that the `all` target and the `clean` target are phony targets, and won't necessarily expect to make files out of them.

In fact, these are the two most common phony targets that we define: `all` typically makes all targets defined in the Makefile at once, while `clean` usually removes all generated targets from the directory. The rules for `all` and `clean` often look something like this:

```bash
# Make all targets
all: $(GENERATED_FILES)

# Remove all generated targets
clean:
    rm -Rf finished/*
```

In this case, the `$(GENERATED_FILES)` dependency should point to a list of all final output targets in the Makefile, and the directory `finished/` should contain all of the files that have been generated. 

#### Automatic Variables

GNU Make comes with some [automatic variables](http://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html#Automatic-Variables) that you can use in your recipe to refer to specific targets or dependencies. Automatic variables act as a shorthand for these targets/dependencies.

The most common automatic variables we use:

| variable | what it refers to |
|---| --- |
| ```$@``` | the filename of the target |
| ```$^``` | the filenames of all dependencies |
| ```$?``` | the filenames of all dependencies that are newer than the target |
| ```$<``` | the filenames of the first dependency |

To see an example of automatic variables in action, let's look back at our rule for generating test scores. The final rule (in pseudocode) looked like this:

```
final_table: clean_schools.csv clean_scores.csv
    join clean_schools.csv clean_scores.csv > final_table
```

Make will accept this syntax, but if the target or dependencies have long filenames it might look messy. We could clean it up using automatic variables like so:

```
final_table: clean_schools.csv clean_scores.csv
    join $^ > $@ 
```

#### Pattern Rules (Implicit Rules)

In cases where you don't want to state targets explicitly, you can write an [implicit rule](https://www.gnu.org/software/make/manual/html_node/Pattern-Rules.html) by including `%` in the target and dependencies. `%` will match any nonempty substring, and the match is called the *stem*.

For an example of a pattern rule, let's look at step 2 of the school Makefile:

```
clean_schools.csv: raw_schools.csv
    edit raw_schools.csv | format > clean_schools.csv
    
clean_scores.csv: raw_scores.csv
    edit raw_scores.csv | format > clean_scores.csv
```

Since our cleaning process is identical for both of these rules, we can collapse them using a pattern rule:

```
clean_%.csv: raw_%.csv
    edit raw_%.csv | format > clean_%.csv
```

Note that we can simplify this even further using automatic variables:

```
clean_%.csv: raw_%.csv
    edit $^ | format > $@
```

**Note:** If your pattern rule fails, check the depedencies. If you've fat-fingered something or omitted the directory by mistake, Make will fail saying a recipe for the target doesn't exist (`make: *** No rule to make target BLAH.  Stop.)`, [when in fact it's the dependency that's missing](https://stackoverflow.com/a/5194141/7142170).

#### Functions for Filenames

There are some convenient [functions](https://www.gnu.org/software/make/manual/html_node/File-Name-Functions.html) for working with a filename or multiple filenames.

Some useful filename functions:

| filename function | what it does |
|---|---|
| ```$(dir [filepaths])``` | returns only the directory path |
| ```$(notdir [filepaths])``` | returns only the file name |

For example, ```$(dir finished/file1.csv finished/file2.csv)``` = ```'finished/ finished/'```, and ```$(notdir finished/file1.csv finished/file2.csv)``` = ```'file1.csv file2.csv'```

## Further Reading

By now, you might feel like a Make expert. That's great! Move on to our [ETL styleguide ("Makefile 301")](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md) to dig into the specifics of how to write a beautiful, DataMade-ready Makefile.

You might also feel really confused about this whole Makefile business. You may ask yourself, "What the heck is a target – is it a file or a variable?" Or, "What's the deal with this phony target thing?" If that sounds like you, don't fret! Make can be confusing if you've never done ETL work before, and with time and practice you'll get the hang of it. Take a look at our [annotated Make examples](http://datamade.github.io/data-making-guidelines/), and then try to annotate your own Makefile. We recommend starting with the [Chicago Lead](https://github.com/City-Bureau/chicago-lead), a well-documented piece of DataMade ETL. For a more challenging Makefile, try to annotate our [Illinois school report cards Makefile](https://github.com/datamade/school-report-cards).
