wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=$1&suffix=zip" --output-document=GeoLite2-ASN.zip --no-check-certificate

unzip GeoLite2-ASN.zip -d .

mv GeoLite2-ASN-CSV*/*.csv .

sed -i 1d *.csv

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

zip -9 -j kusto-cidr-asn.csv.zip kusto-cidr-asn.csv
zip -9 -j kusto-cidr-asn-ipv6.csv.zip kusto-cidr-asn-ipv6.csv

python3 generateparquet.py

ls -lha