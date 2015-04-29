# Making Data, the DataMade Way

This is [DataMade's](http://datamade.us) guide to **extracting**, **transforming** and **loading** (ETL) data using [Make](http://en.wikipedia.org/wiki/Make_%28software%29), a common command line utility.

ETL refers to the general process of:

1. taking raw **source data** (Extract)
2. doing some stuff to get the data in shape, possibly involving intermediate **derived files** (Transform)
3. & ultimately ending up with **final output** in a usable form (for Loading into something that consumes the data - be it an app, a system, a visualization, etc.)

For enthralling insights on how to get from source data to final output, all while minimizing future headaches - read on!

## Principles

1. Treat inputs as immutable - don't modify source data directly
2. Be able to deterministically produce the final data with one command 
3. Write as little custom code as possible 
4. Use [standard tools](#standard-toolkit) whenever possible
5. Source data should be under version control

## The Guide

1. [Make & Makefile Overview](https://github.com/datamade/data-making-guidelines/blob/master/make.md)
2. [ETL Styleguide](https://github.com/datamade/data-making-guidelines/blob/master/styleguide.md)

## Code examples
- [Some Annotated ETL Code Examples with Make](http://datamade.github.io/data-making-guidelines/)
- [Gary Counts Repo](https://github.com/datamade/gary-counts-data)
- [Trees Repo](https://github.com/fgregg/trees)

## Further reading
- [Makefile Style Guide by Clark Grubb](http://clarkgrubb.com/makefile-style-guide#data-workflows)
- [Why Use Make by Mike Bostock](http://bost.ocks.org/mike/make/)
