# Description
---
This project takes ASN IP data from Maxmind and formats it in a way that is useful and appropiate for Microsoft KQL applications.  Appropiate products include Microsoft Defender for Endpoing, Sentinel, Azure Monitor, Azure Log Analytics and Azure Data Explorer.

# License
---
Output data and generation code is provided under [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).

# Source
---
This product includes GeoLite2 data created by MaxMind, available from [https://www.maxmind.com](https://www.maxmind.com).

# Why should I use this data?
---
Allows the ability to track IP addresses across service providers as well as investigate the whole address space for specific details.

# Perma Link
---
[https://github.com/gypthecat/shiny-adventure/releases/download/Test01/kusto-cidr-asn.csv.zip](https://github.com/gypthecat/shiny-adventure/releases/download/Test01/kusto-cidr-asn.csv.zip)

# History
---
This dataset is simultaneously hosted on https://firewalliplists.gypthecat.com.

# Schema
| Column Name | Data Type | Notes |
| ----------- | --------- | ----- |
| CIDR | string  | |
| CIDRASN | int  | |  
| CIDRASNName | string  | |  
| CIDRSource | string  | Always Maxmind |  

# Base Kusto Table
---
```
externaldata (CIDR:string, CIDRASN:int, CIDRASNName:string, CIDRSource:string) ['https://github.com/gypthecat/shiny-adventure/releases/download/Test01/kusto-cidr-asn.csv.zip'] with (ignoreFirstRecord=true)
```

## Base Kusto Function
---
```
let CIDRASN = (externaldata (CIDR:string, CIDRASN:int, CIDRASNName:string, CIDRSource:string) ['https://firewalliplists.gypthecat.com/lists/kusto/kusto-cidr-asn.csv.zip'] with (ignoreFirstRecord=true));
```
