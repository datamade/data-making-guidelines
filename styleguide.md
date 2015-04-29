## [Making Data, the DataMade Way](https://github.com/datamade/data-making-guidelines/blob/master/README.md)
1. [Make & Makefile Overview](https://github.com/datamade/data-making-guidelines/blob/master/make.md)
2. **ETL Styleguide**

# ETL Styleguide

## Contents

1. [Makefile Best Practices](#1-makefile-best-practices)
2. [Variables](#2-variables)
3. [Processors](#3-processors)
4. [Standard Toolkit](#4-standard-toolkit)
5. [ETL Workflow Directory Structure](#5-etl-workflow-directory-structure)

### 1. Makefile Best Practices

Some loose notes on best practices:
- Some transformations, especially those chaining unix tools, are obscure. Consider printing the purpose of the transformation ```@echo "Downcasing the header of this csv"```
- Always echo commands.
- To limit verbosity, use arg flags. Avoid piping stderr to dev/null
- List recipes in rough order of processing steps
- Have 'all' and 'clean' phony targets
- Prefer implicit patterns over explicit recipes. Encourages DRY and files created by implicit patterns will automatically be cleaned up. 
- When implicit patterns are not attractive, set intermediate build files as dependencies of the `.INTERMEDIATE` target. Make will clean up these files for you.
- Makefile directives go at the top file, followed by variables go at the top of the file, followed by 'all' and 'clean' targets
- Use these Makefile directives
```make
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
```


### 2. Variables
Variables are names defined in a makefile to refer to files, directories, targets, or just about anything that you can represent with text.

**A few common variables we define:**

| variable | description |
|---|---|
| ```GENERATED_FILES``` | a list of all the final output targets that the makefile can build. this is used as a shorthand way of calling everything in the ```all``` [phony target](https://github.com/datamade/data-making-guidelines#phony-targets) |
| ```DATA_DIRS``` | if there is a master makefile and sub-makefiles, this includes all of the sub-directories. it is useful for the ```all``` [phony target](https://github.com/datamade/data-making-guidelines#phony-targets) in the master makefile |
| ```DIR``` | points to the directory that contains the master makefile |
| ```PYTHON_BIN``` | if a Python Virtual Environment needs to be created, this points to the ```bin/``` directory inside that virtual environment |
| ```PROCESSOR_DIR``` | if the workflow requires [processors](https://github.com/datamade/data-making-guidelines#processors), this points at the directory containing the processors |

If you have a master makefile and multiple sub-makefiles, you should define ```GENERATED_FILES``` in each sub-makefile, and the other variables above in the master makefile.

### 3. Processors
When processing a target requires more than can be accomplished with our [standard toolkit](https://github.com/datamade/data-making-guidelines#standard-toolkit), a processor (i.e. a script for a single operation) can be written.

For the sake of easier reuse, each processor should be modular, only handling one operation on a file. Each processor should be configured to accept input on ```STDIN``` and write output to ```STDOUT```, so that it's easy to chain processors and operations.

All processors should live in a ```processors/``` directory in the root of the repository. To make processors available to all makefiles, define the path to ```processors/``` in the ```PROCESSORS``` [variable](https://github.com/datamade/data-making-guidelines#variables).

Some examples of single-purpose processors:
- [excel date column -> ISO formatted date column](https://github.com/datamade/gary-counts-data/blob/master/data/processors/convert_excel_time.py)
- ['NA' or 'N/A' -> None](https://github.com/datamade/gary-counts-data/blob/master/data/processors/make_real_nulls.py)
- [delete empty rows from a csv](https://github.com/datamade/gary-counts-data/blob/master/data/processors/delete_empty_rows.py)
- [strip whitespace in a csv](https://github.com/datamade/gary-counts-data/blob/master/data/processors/strip_whitespace.py)

## 4. Standard Toolkit

- For fetching content on the web, use wget. Use `--no-use-server-timestamps` arg for wget.
- For manipulating geo files, use GDAL/OGR 
- CSVKit for spreadsheets, or things that can be made into spreadsheets. In particular
  -  [```in2csv```](https://csvkit.readthedocs.org/en/0.9.1/scripts/in2csv.html)    
  -  [```csvcut```](https://csvkit.readthedocs.org/en/0.9.1/scripts/csvcut.html)
  -  [```csvjoin```](https://csvkit.readthedocs.org/en/0.9.1/scripts/csvjoin.html) 
- For simple sql-like queries use csvkit
- For more complicated queries use postgres
- For geospatial queries use postgis
- For text manipulation use sed, unless it's **much** easier to do it with awk
- CSVKit for spreadsheets, or things that can be made into spreadsheets
- unzip, gzip, and tar for uncompressed files. If you are compressing files, and have an option, use tar zcvf
- For custom transform code, use Python

### 5. ETL Workflow Directory Structure

In the case that a project has multiple separate data components, you can define a master makefile at the root of the repository, along with sub-directories that each have a sub-makefile at the root. When using this type of nested structure, all data processing/transformation should be defined in the sub-makefiles - the master makefile should only handle setting up the environment, defining variables/targets used by multiple sub-makefiles, & calling sub makefiles.

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
