# Making Data, the DataMade Way

This is [DataMade's](http://datamade.us) guide to **extracting**, **transforming** and **loading** (ETL) data using [Make](http://en.wikipedia.org/wiki/Make_%28software%29), a common command line utility.

ETL refers to the general process of:

1. taking raw **source data** (*"Extract"*)
2. doing some stuff to get the data in shape, possibly involving intermediate **derived files** (*"Transform"*)
3. producing **final output** in a more usable form (for *"Loading"* into something that consumes the data - be it an app, a system, a visualization, etc.)

Having a standard ETL workflow helps us make sure that our work is clean, consistent, and easy to reproduce. By following these guidelines you'll be able to keep your work up to date and share it with the world in a standard format - all with as few headaches as possible.

## Basic Principles

These five principles inform all of our data work:

1. **Never destroy data** - treat source data as immutable, and show your work when you modify it
2. Be able to deterministically **produce the final data with one command**
3. Write as **little custom code** as possible
4. Use **[standard tools](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md#4-standard-toolkit)** whenever possible
5. Keep source data under **version control**

Unsure how to follow these principles? Read on!

## The Guide

1. [Make & Makefile Overview](https://github.com/datamade/data-making-guidelines/blob/master/make.md)
    - [Why Use Make/Makefiles?](https://github.com/datamade/data-making-guidelines/blob/master/make.md#1-why-use-makemakefiles)
    - [Makefile 101](https://github.com/datamade/data-making-guidelines/blob/master/make.md#2-makefile-101)
    - [Makefile 201 - Some Fancy Things Built Into Make](https://github.com/datamade/data-making-guidelines/blob/master/make.md#3-makefile-201---some-fancy-things-built-into-make)
2. [ETL Styleguide](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md)
    - [Makefile Best Practices](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md#1-makefile-best-practices)
    - [Variables](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md#2-variables)
    - [Processors](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md#3-processors)
    - [Standard Toolkit](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md#4-standard-toolkit)
    - [ETL Workflow Directory Structure](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md#5-etl-workflow-directory-structure)

## Code examples
- [Some Annotated ETL Code Examples with Make](http://datamade.github.io/data-making-guidelines/)
- [Chicago Lead](https://github.com/City-Bureau/chicago-lead) - data work with a clear README and Makefile
- [EITC Works](https://github.com/datamade/eitc-map/tree/master/data) - adding data attributes to Illinois House and Senate district shapefiles and outputting at GeoJSON

## Further reading
- [Makefile Style Guide by Clark Grubb](http://clarkgrubb.com/makefile-style-guide#data-workflows)
- [Why Use Make by Mike Bostock](http://bost.ocks.org/mike/make/)
