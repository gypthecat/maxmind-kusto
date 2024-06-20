import pandas as pd
dataasnipv4 = pd.read_csv('kusto-cidr-asn.csv')
dataasnipv4.to_parquet('kusto-cidr-asn.parquet', compression='gzip')
dataasnipv6 = pd.read_csv('kusto-cidr-asn-ipv6.csv')
dataasnipv6.to_parquet('kusto-cidr-asn-ipv6.parquet', compression='gzip')