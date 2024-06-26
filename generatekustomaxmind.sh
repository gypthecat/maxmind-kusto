#!/bin/bash

# Prepare directory for staging
mkdir -p artifacts

# Download from Maxmind
wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=$1&suffix=zip" --output-document=GeoLite2-ASN.zip --no-check-certificate

# Unzip to here
unzip GeoLite2-ASN.zip -d .

# Move the files to this directory
mv GeoLite2-ASN-CSV*/*.csv .

# Remove the top rows of the CSVs
sed -i 1d *.csv

# Create tables to import the data
echo '
CREATE TABLE CIDRASNIPV4(
  "CIDR" TEXT,
  "CIDRASN" TEXT,
  "CIDRASNName" TEXT
);
.schema
' | sqlite3 temp.db

echo '
CREATE TABLE CIDRASNIPV6(
  "CIDR" TEXT,
  "CIDRASN" TEXT,
  "CIDRASNName" TEXT
);
.schema
' | sqlite3 temp.db

# Import the data
echo '
.mode csv
.import GeoLite2-ASN-Blocks-IPv4.csv CIDRASNIPV4
' | sqlite3 temp.db

echo '
.mode csv
.import GeoLite2-ASN-Blocks-IPv6.csv CIDRASNIPV6
' | sqlite3 temp.db

# Export kusto-cidr-asn.csv
echo '
.headers on
.mode csv
.output kusto-cidr-asn.csv
SELECT CIDR, CIDRASN, CIDRASNName, "GeoLite2 by MaxMind" as CIDRSource FROM CIDRASNIPV4;
' | sqlite3 temp.db

# Export kusto-cidr-asn-ipv6.csv
echo '
.headers on
.mode csv
.output kusto-cidr-asn-ipv6.csv
SELECT CIDR, CIDRASN, CIDRASNName, "GeoLite2 by MaxMind" as CIDRSource FROM CIDRASNIPV6;
' | sqlite3 temp.db

# Compress the files
zip -9 -j artifacts/kusto-cidr-asn.csv.zip kusto-cidr-asn.csv
zip -9 -j artifacts/kusto-cidr-asn-ipv6.csv.zip kusto-cidr-asn-ipv6.csv

# Necessary Python packages
pip install pandas fastparquet pyarrow

# Generate Parquet files
#python3 generateparquet.py
for inputfiles in kusto*.csv;
  do python3 converttoparquet.py $inputfiles;
done

mv *.parquet artifacts/

# Sanity check contents
ls -lha
ls -lha artifacts/

# You can do something here with the files, eg upload elsewhere
