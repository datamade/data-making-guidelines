1. Setup phony targets

    ```make
    .PHONY: all clean 

    all: $(GENERATED_FILES) 

    clean: 
        rm -Rf finished/*
    ```

2. Downloading a zip directory

    ```make
    parcels.zip: 
        wget --no-use-server-timestamps \ 
        http://maps.indiana.edu/download/Reference/Land_Parcels_County_IDHS.zip -O $@
    ```
Notice the use of `--no-use-server-timestamps`. If you didn't use this argument, 
this file would have a last-touched timestamp of the file on the server. By 
using this argument, the file will have a timestamp of when it was downloaded.


3. Unzipping a zip directory

    ```make
    .INTERMEDIATE: chicomm.shp
    chicomm.shp: chicomm.zip 
        unzip -o $<
    ```

4. Converting excel to csv

    ```make
    .INTERMEDIATE: parcel_survey.csv
    parcel_survey.csv: parcel_survey.xlsx 
        in2csv $< > $@
    ```

5. Grabbing select columns from an excel doc, & creating a csv with a new header

    ```make
    school_id_lookup.csv: School_data_8-3-14.xlsx 
        in2csv $< |\ 
        csvcut -c "1,2" |\ 
        (echo "school_id,school_name"; tail -n +2) > finished/$(notdir $@)
    ```

6. Join csvs, using an implicit rule

    ```make
    %hourly.joined.csv: %hourly.csv stations.csv 
        csvjoin -c "3,4" $< $(word 2,$^) > finished/$(notdir $@)
    ```

7. Substitute many versions of the same thing, such as a different URLs for each 
year of an annual report, into a common recipe 

    ```make
    BASE_URL=www.mydatais.cool
    URL_2010=$(BASE_URL)/2010/summary.csv
    URL_2011=$(BASE_URL)/2011/summery.csv
    URL_2012=$(BASE_URL)/2012/data-summary.csv

    YEARS=2010 2011 2012

    COOL_DATA=$(patsubst %, data_%.csv, $(YEARS))


    data_%.csv : 
        wget --no-use-server-timestamps -O $@ $(URL_$*)
    ```

Call `make $cool_data` or set `$(COOL_DATA)` as a dependency of another target 
to automagically run your pattern recipe for all defined URLs.

This pattern is also useful when grabbing data from large datasets where column 
names change over time.

Read more on `patsubst` [in the Make docs](https://www.gnu.org/software/make/manual/html_node/Text-Functions.html).
