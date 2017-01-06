## [Making Data, the DataMade Way](https://github.com/datamade/data-making-guidelines/blob/master/README.md)
1. [Make & Makefile Overview](https://github.com/datamade/data-making-guidelines/blob/master/make.md)
2. **ETL Styleguide**

# ETL Styleguide
*AKA "Makefile 301"*

This page defines the DataMade styleguide for processing data, a collection of "best practices" for writing Makefiles. 

To make use of this page, you should already have a good understanding of [what Make is and why we use it.](https://github.com/datamade/data-making-guidelines/blob/master/make.md) You should also be comfortable with [bash syntax and the Unix filesystem](http://ryanstutorials.net/bash-scripting-tutorial/).

## Contents

1. [Makefile Best Practices](#1-makefile-best-practices)
2. [Variables](#2-variables)
3. [Processors](#3-processors)
4. [Standard Toolkit](#4-standard-toolkit)
5. [ETL Workflow Directory Structure](#5-etl-workflow-directory-structure)

### 1. Makefile Best Practices

Some loose notes on best practices:

#### Show your work
- Some transformations, especially those chaining Unix tools, are obscure. Consider printing the purpose of the transformation (as in: `@echo "Downcasing the header of this csv"`)
- Do not suppress output to the console. Being able to see commands as they execute helps users debug errors.
- Avoid piping stderr to dev/null.
- When possible, list recipes in rough order of processing steps (from start to finish).

#### Stay [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself)
- To limit verbosity, use [arg flags](https://gobyexample.com/command-line-flags) and [automatic variables](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html). 
- Define 'all' and 'clean' phony targets for keeping the repo clean.
- Prefer implicit patterns over explicit recipes. Implicit patterns are DRY, and files created by implicit patterns will automatically be cleaned up.

#### Keep things clean
- When implicit patterns are not attractive, set intermediate build files as dependencies of the `.INTERMEDIATE` target. Make will clean up these files for you.
- Makefile directives go at the top of the file, followed by variables, followed by 'all' and 'clean' targets.
- Use these Makefile directives as a default:
```make
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
```

#### A note on cleanliness
It's best to use implicit rules and .INTERMEDIATE targets to have Make clean up intermediate files for you. Sometimes, though, this is not so easy. In particular, if a step in the build process emits multiple files, only some of which will be dependencies, it's not very easy to get Make to clean up everything. This happens frequently when working with ESRI shapefiles which include a .prj, .dbf, .xml, and other files in addition to the .shp file. 

To handle these types of issues, define a .PHONY cleanup target for everything that Make misses, and document the cleanup target in the README.

### 2. Variables
Variables are names defined in a Makefile to refer to files, directories, targets, or just about anything that you can represent with text. They are defined in `ALL_CAPS`, and referred to with the same syntax as `$(BASH_VARIABLES)`. 

**A few common variables we define:**

| variable | description |
|---|---|
| ```GENERATED_FILES``` | A list of all the final output targets that the Makefile can build. This is used as a shorthand way of calling everything in the `all` [phony target](https://github.com/datamade/data-making-guidelines#phony-targets). |
| ```DATA_DIRS``` | If there is a master Makefile with imported sub-Makefiles, this includes all of the sub-directories. It is useful for the `all` [phony target](https://github.com/datamade/data-making-guidelines#phony-targets) in the master Makefile. |
| ```DIR``` | Points to the directory that contains the master Makefile. |
| ```PYTHON_BIN``` | If a Python Virtual Environment needs to be created, this points to the ```bin/``` directory inside that virtual environment. |
| ```PROCESSOR_DIR``` | If the workflow requires [processors](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md#3-processors), this points at the directory containing the processors. |

If you have a master Makefile and multiple sub-Makefiles, you should define ```GENERATED_FILES``` in each sub-Makefile, and the other variables above in the master Makefile.

### 3. Processors
When processing a target requires more than can be accomplished with our [standard toolkit](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md#4-standard-toolkit), a processor (i.e. a script for a single operation, often written in Python) can be written.

For the sake of easier reuse, each processor should be modular, only handling one operation on a file. Each processor should be configured to accept input on ```STDIN``` and write output to ```STDOUT```, so that it's easy to chain processors and operations.

All processors should live in a ```processors/``` directory in the root of the repository. To make processors available to all Makefiles, define the path to ```processors/``` in the ```PROCESSORS``` [variable](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md#variables).

Some examples of single-purpose processors:
- [excel date column -> ISO formatted date column](https://github.com/datamade/gary-counts-data/blob/master/data/processors/convert_excel_time.py)
- ['NA' or 'N/A' -> None](https://github.com/datamade/gary-counts-data/blob/master/data/processors/make_real_nulls.py)
- [delete empty rows from a csv](https://github.com/datamade/gary-counts-data/blob/master/data/processors/delete_empty_rows.py)
- [strip whitespace in a csv](https://github.com/datamade/gary-counts-data/blob/master/data/processors/strip_whitespace.py)

## 4. Standard Toolkit

- For fetching content on the web, use **wget**. Use the `--no-use-server-timestamps` flag so you don't download it every time Make runs; use the `-O` flag to define a custom filepath for the output.
- For manipulating geo files use **GDAL/OGR**. 
- Use **CSVkit** for manipulating spreadsheets, or things that can be made into spreadsheets. In particular:
  -  [```in2csv```](https://csvkit.readthedocs.org/en/0.9.1/scripts/in2csv.html)    
  -  [```csvcut```](https://csvkit.readthedocs.org/en/0.9.1/scripts/csvcut.html)
  -  [```csvjoin```](https://csvkit.readthedocs.org/en/0.9.1/scripts/csvjoin.html) 
- For simple SQL-like queries use CSVkit; for more complicated queries use **postgreSQL**.
- For geospatial queries use **postgis**.
- For text manipulation use **[perl](https://luv.asn.au/overheads/perl/man.html)** (like sed but without portability issues), unless it's substantially easier to do it with awk.
- **unzip**, **gzip**, and **tar** for decompressing files. If you are compressing files and have the option, use **tar zcvf**.
- For custom transform code, write **Python scripts**.

In general, prefer [simple Unix tools](http://physics.oregonstate.edu/~landaur/nacphy/coping-with-unix/node145.html) to custom scripts (processors). When a processor is absolutely necessary, try to follow the [Unix philosophy](http://www.faqs.org/docs/artu/ch01s06.html) ("do one thing and do it well").

### 5. ETL Workflow Directory Structure

In the case that a project has multiple separate data components, you can define a master Makefile at the root of the repository, along with sub-directories that each have a sub-Makefile at the root. When using this type of nested structure, all data processing/transformation should be defined in the sub-Makefiles - the master Makefile should only handle setting up the environment, defining variables/targets used by multiple sub-Makefiles, and calling sub-Makefiles.

```
|-- Makefile  # the master makefile
|-- README.md
|-- data/
|   |-- <sub-directory for a data processing component>
|   |   |-- Makefile   # a sub-makefile
|   |   |-- README.md  # documents the data source & how data gets processed
|   |   |-- finished/  # a directory for finished files
|   |-- <sub-directory for another data processing component>
|   |   |-- Makefile   # a sub-makefile
|   |   `-- < ... etc ... >
|-- processors
|   |-- <processor_name>.py
|   `-- <another_processor_name>.sh
`-- requirements.txt   # lists install requirements for the pipeline
```
