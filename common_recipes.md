1. Setup phony targets

    ```
    .PHONY: all clean 

    all: $(GENERATED_FILES) 

    clean: 
        rm -Rf finished/*
    ```

2. Downloading a zip directory

    ```
    parcels.zip: 
        wget --no-use-server-timestamps \ 
        http://maps.indiana.edu/download/Reference/Land_Parcels_County_IDHS.zip -O $@
    ```
Notice the use of `--no-use-server-timestamps`. If you didn't use this argument, this file would have a last-touched timestamp of the file on the server. By using this argument, the file will have a timestamp of when it was downloaded.


3. Unzipping a zip directory

    ```
    .INTERMEDIATE: chicomm.shp
    chicomm.shp: chicomm.zip 
        unzip -o $<
    ```

4. Converting excel to csv

    ```
    .INTERMEDIATE: parcel_survey.csv
    parcel_survey.csv: parcel_survey.xlsx 
        in2csv $< > $@
    ```

5. Grabbing select columns from an excel doc, & creating a csv with a new header

    ```
    school_id_lookup.csv: School_data_8-3-14.xlsx 
        in2csv $< |\ 
        csvcut -c "1,2" |\ 
        (echo "school_id,school_name"; tail +2) > finished/$(notdir $@)
    ```

6. Join csvs, using an implicit rule

    ```
    %hourly.joined.csv: %hourly.csv stations.csv 
        csvjoin -c "3,4" $< $(word 2,$^) > finished/$(notdir $@)
    ```

7. Load data from a CSV into a table using Postgres.

    ```
    taxes.table: taxes.csv
        psql -c "CREATE TABLE $(basename $@) ( \
                /* schema for the table goes here */ \
            )"
        psql -c
            "COPY $(basename $@) \
             FROM STDIN WITH CSV QUOTE AS '\"' \
             DELIMITER AS ','"
        touch $@
    ```

8. Load data from a Shapefile into a table using Postgres.
    ```
    addresses.table: addresses.shp
        shp2pgsql -I -s 4326 -d $< $(basename $@) | psql
        touch $@
    ```