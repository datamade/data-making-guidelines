## Make & Makefiles

To achieve a reproducible data workflow, we use [GNU's make](http://en.wikipedia.org/wiki/Make_%28software%29).

## Contents

1. [Why Use Make/Makefiles?](#why-use-makemakefiles)
2. [Makefile 101](#makefile-101)
3. [Makefile 201 - Some Fancy Things Built Into Make](#makefile-201---some-fancy-things-built-into-make)


### 1. Why Use Make/Makefiles?
A simple way of thinking about a data processing workflow is as a series of steps. However, instead of thinking *forward*, in terms of an order of steps from step 1 to step N, you can also also think *backwards* - in terms of the outputs that you want and the files that those outputs are derived from. Thinking backwards is a more powerful way of expressing a data workflow, since dependencies aren't always linear.

```make``` is a build tool that generates file *targets*, each of which can depend upon the existence of other files (*dependencies*). Targets, dependencies, and instructions specifying to build them are defined in a *makefile*. The nice thing about makefiles is that once you specify a dependency graph, ```make``` will do the work of figuring out the individual steps required to build an output, based on your rules and the files you already have.

**```make``` is a particularly nifty tool for data processing because**:
- ```make``` allows you to create all final data with a single command, since ```make``` rules can be chained. writing a ```makefile``` is ultimately an exercise in making your existing data processing steps explicit, to ultimately avoid manual, undocumented steps
- ```make``` is smart about only building what's necessary, because it's aware of when a file was last modified - ```make``` will not rebuild existing files if their dependencies haven't changed.
- ```make``` give you parallel processing for nearly free


### 2. Makefile 101
When you run a ```make``` command, ```make``` will look for instructions in a file called ```Makefile``` in the current directory. The building block of a makefile is a "rule". Each "rule" specifies (1) a *target*, (2) the target's *dependencies*, and the target's *recipe* (i.e. the commands for creating the target).

**The general structure of a single make "rule":**
```
target: dependencies
[tab] recipe
```
**Targets** - the target is what you want to generate. ```make``` expects all targets to be files, with the exception of [phony target](https://github.com/datamade/data-making-guidelines#phony-targets). a file target can be an output filename, an output file pattern, or a [variable](https://github.com/datamade/data-making-guidelines#variables).  
**Dependencies** - dependencies are everything that needs to exist in order to make the target. ```make``` expects all dependencies to be files. dependencies can be filenames, filename patterns, or [variables](https://github.com/datamade/data-making-guidelines#variables). dependencies are optional.   
**Recipes** - recipes are commands for generating the target file. any command you can run on the terminal is fair game  for recipes - bash commands, invoking a script, etc.  

### 3. Makefile 201 - Some Fancy Things Built Into Make

The following is not complete documentation of ```make``` functionality - just some stuff we use most often.

#### Phony Targets

By default, ```make``` assumes that targets are files. However, sometimes it is useful to run commands that do not represent physical files - for example, making all targets or cleaning your directory. To define phony targets, you must explicitly tell ```make``` that they are not associated with files, like so:
```
.PHONY: all clean
```
The most common examples of phony targets that we use are ```all``` (make all targets defined in the makefile) and ```clean``` (clean all derived files).

Example rules for these common commands:
```
all: $(GENERATED_FILES)

clean:
    rm -Rf finished/*
```
*Note: for the ```$(GENERATED_FILES)``` dependency, ```GENERATED_FILES``` should be a variable defined to include all final output targets in a makefile*

#### Automatic Variables
GNU make comes with some [automatic variables](http://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html#Automatic-Variables) that you can use *in your recipe* to refer to specific targets/dependencies.

The most common automatic variables we use:

| variable | what it refers to |
|---|---|
| ```$@``` | the filename of the target |
| ```$^``` | the filenames of all dependencies |
| ```$?``` | the filenames of all dependencies that are newer than the target |
| ```$<``` | the filenames of the first dependency |

#### Pattern Rules (Implicit Rules)

In cases where you don't want to state targets explicitly, you can write an [implicit rule](https://www.gnu.org/software/make/manual/html_node/Pattern-Rules.html) by including ```%``` in the target and dependencies - ```%``` will match any nonempty substring, and the match is called the *stem*.

#### Functions for Filenames

There are some convenient [functions](https://www.gnu.org/software/make/manual/html_node/File-Name-Functions.html) for working with a filename or multiple filenames.

Some useful filename functions:

| filename function | what it does |
|---|---|
| ```$(dir [filepaths])``` | returns only the directory path |
| ```$(notdir [filepaths])``` | returns only the file name |

For example, ```$(dir finished/file1.csv finished/file2.csv)``` = ```'finished/ finished/'``` & ```$(notdir finished/file1.csv finished/file2.csv)``` = ```'file1.csv file2.csv'```
