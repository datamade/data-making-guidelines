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
        csvjoin -c "3,4" $< stations.csv > finished/$(notdir $@)
    ```