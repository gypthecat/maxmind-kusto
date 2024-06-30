# Description
This project takes ASN and geographic IP data from MaxMind daily and formats it in a way that is useful and appropiate for Microsoft KQL/Kusto applications.  Appropiate products include Microsoft Defender for Endpoint, Microsoft Sentinel, Azure Monitor, Azure Log Analytics and Azure Data Explorer.

# License
Output data and generation code is provided under [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).

# Source
This product includes GeoLite2 data created by MaxMind, available from [https://www.maxmind.com](https://www.maxmind.com).

# Why should I use this data?
Allows the ability to track IP addresses across service providers as well as investigate the whole address space for specific details.

# Perma Link
[https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-asn.csv.zip](https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-asn.csv.zip)
[https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-asn.parquet](https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-asn.parquet)
[https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-asn-ipv6.csv.zip](https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-asn-ipv6.csv.zip)
[https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-asn-ipv6.parquet](https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-asn-ipv6.parquet)
[https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-countries.csv.zip](https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-countries.csv.zip)
[https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-countries.parquet](https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-countries.parquet)

# Schema kusto-cidr-asn.csv.zip
| Column Name | Data Type | Notes |
| ----------- | --------- | ----- |
| CIDR | string  | |
| CIDRASN | int  | |  
| CIDRASNName | string  | |  
| CIDRSource | string  | Always MaxMind |

# Schema kusto-cidr-countries.csv.zip
| Column Name | Data Type | Notes |
| ----------- | --------- | ----- |
| CIDRCountry | string | |
| CIDR | string | |
| CIDRCountryName | string | |
| CIDRContinent | string | |
| CIDRContinentName | string | |
| CIDRSource | string | Always MaxMind |

# Base Kusto Table kusto-cidr-asn.csv.zip
```
externaldata (CIDR:string, CIDRASN:int, CIDRASNName:string, CIDRSource:string) ['https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-asn.csv.zip'] with (ignoreFirstRecord=true)
```

# Base Kusto Table kusto-cidr-countries.csv.zip
```
externaldata (CIDRCountry:string, CIDR:string, CIDRCountryName:string, CIDRContinent:string, CIDRContinentName:string, CIDRSource:string) ['https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-countries.csv.zip'] with (ignoreFirstRecord=true)
```

# Self Contained Kusto Example #1 - ASN IP Data
```
// Which ASN Owners have the most IP address?
let CIDRASN = (externaldata (CIDR:string, CIDRASN:int, CIDRASNName:string, CIDRSource:string) ['https://github.com/gypthecat/maxmind-kusto/releases/download/daily-run/kusto-cidr-asn.csv.zip'] with (ignoreFirstRecord=true));
CIDRASN
| extend NumberOfIPs = pow(2, 32 - toint(split(CIDR, '/')[-1]))
| summarize TotalIPs = sum(NumberOfIPs) by CIDRASN, CIDRASNName
| order by TotalIPs desc
```

# Self Contained Kusto Example #2 - Geo IP Data
```
// Comparing inbuilt Kusto geo functions and external records what is the delta?
// Note: This just helps clarify the difficulties in using such threat intelligence
// Note: If CIDR blocks have been split these won't necessarily be picked up
externaldata (CIDRCountry:string, CIDR:string, CIDRCountryName:string, CIDRContinent:string, CIDRContinentName:string, CIDRSource:string) ['https://firewalliplists.gypthecat.com/lists/kusto/kusto-cidr-countries.csv.zip'] with (ignoreFirstRecord=true)
| extend IndicativeIpAddress = tostring(split(CIDR, '/')[0])
| extend CountryName = geo_info_from_ip_address(IndicativeIpAddress)['country']
| where CIDRCountryName !in ('IETF', '') and CountryName !in ('') and CIDRCountryName != CountryName
| extend NumberOfIPs = pow(2, 32 - toint(split(CIDR, '/')[-1]))
| extend Countries = bag_pack("Countries", array_sort_asc(pack_array(CIDRCountryName, CountryName)))
| summarize NumberOfIPs = sum(NumberOfIPs) by tostring(Countries)
| render piechart
```

# I Want to Generate the Data Myself?
Instructions coming soon.

# History
This dataset is simultaneously hosted on https://firewalliplists.gypthecat.com.

# About Me
#MicrosoftEmployee yet all code regardless of quality and suitability is entirely on me, comments and verbiage entirely my own as a personal pet project.
