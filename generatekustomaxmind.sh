#!/bin/bash

# Prepare directory for staging
mkdir -p artifacts

# Download from Maxmind
wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=$1&suffix=zip" --output-document=GeoLite2-ASN.zip --no-check-certificate
wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=$1&suffix=zip" --output-document=GeoLite2-Geo.zip --no-check-certificate

# Unzip to here
unzip GeoLite2-ASN.zip -d .
unzip GeoLite2-Geo.zip -d .

# Move the files to this directory
mv GeoLite2-ASN-CSV*/*.csv .
mv GeoLite2-Country-CSV*/*.csv .

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

echo '
CREATE TABLE CIDR(
  "CIDR" TEXT,
  "CountryID" TEXT,
  "registered_country_geoname_id" TEXT,
  "represented_country_geoname_id" TEXT,
  "is_anonymous_proxy" TEXT,
  "is_satellite_provider" TEXT,
  "is_anycast" TEXT
);
.schema
' | sqlite3 temp.db

echo '
CREATE TABLE CIDRLocations(
  "CountryID" TEXT,
  "locale_code" TEXT,
  "CIDRContinent" TEXT,
  "CIDRContinentName" TEXT,
  "CIDRCountry" TEXT,
  "CIDRCountryName" TEXT,
  "is_in_european_union" TEXT
);
.schema
' | sqlite3 temp.db

# Import the data
echo '
.mode csv
.import GeoLite2-ASN-Blocks-IPv4.csv CIDRASNIPV4
.import GeoLite2-ASN-Blocks-IPv6.csv CIDRASNIPV6
.import GeoLite2-Country-Locations-en.csv CIDRLocations
.import GeoLite2-Country-Blocks-IPv4.csv CIDR
' | sqlite3 temp.db

#echo '
#.mode csv
#.import GeoLite2-ASN-Blocks-IPv6.csv CIDRASNIPV6
#' | sqlite3 temp.db

# Create Maxmind GeoIP countries
echo '
CREATE TABLE kustocountries AS
SELECT CIDR.CIDR, CIDRLocations.CIDRCountry, CIDRLocations.CIDRCountryName, CIDRLocations.CIDRContinent, CIDRLocations.CIDRContinentName
FROM CIDR 
inner join CIDRLocations on CIDR.CountryID = CIDRLocations.CountryID;
' | sqlite3 temp.db

# Export kusto-cidr-countries.csv
echo '
.headers on
.mode csv
.output kusto-cidr-countries.csv
SELECT CIDRCountry, CIDR, CIDRCountryName, CIDRContinent, CIDRContinentName, "GeoLite2 by MaxMind" as CIDRSource FROM kustocountries;
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
zip -9 -j artifacts/kusto-cidr-countries.csv.zip kusto-cidr-countries.csv

# Necessary Python packages
pip install pandas fastparquet pyarrow

# Generate Parquet files
for inputfiles in kusto*.csv;
  do python3 converttoparquet.py $inputfiles;
done

mv *.parquet artifacts/

# Generate SHA1 values
sha1sum artifacts/* > artifacts/hash-values.txt

# Sanity check contents
ls -lhaFR

# You can do something here with the files, eg upload elsewhere
# In this case updating the release on GitHub
gh release upload --repo gypthecat/maxmind-kusto daily-run artifacts/* --clobber
