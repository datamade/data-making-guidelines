# :sparkles:Making Data, the DataMade Way:sparkles:

This is documentation for the DataMade ETL workflow.

ETL refers to the general process of:

1. taking raw **source data** (Extract)
2. doing some stuff to get the data in shape, possibly involving intermediate **derived files** (Transform)
3. & ultimately ending up with **final output** in a usable form (for Loading into something that consumes the data - be it an app, a system, a visualization, etc.)

For enthralling insights on how to get from source data to final output, all while minimizing future headaches - read on!

## DataMade's Data Making Principles

- Treat inputs as immutable - don't modify source data directly
- Be able to deterministically produce the final data with one command 
- Write as little custom code as possible 
- Use [standard tools](#standard-toolkit) whenever possible
- Source data should be under version control

## Example Repositories
- [Gary Counts](https://github.com/datamade/gary-counts-data)
- [Trees](https://github.com/fgregg/trees)

## Related Links
- [Makefile Style Guide by Clark Grubb](http://clarkgrubb.com/makefile-style-guide#data-workflows)
- [Why Use Make by Mike Bostock](http://bost.ocks.org/mike/make/)
