import sys
import pandas
import datetime

txt = str(sys.argv[1])

print(f'{datetime.datetime.now()} - Info - CSV to Parquet conversion - Starting File Name {txt}')

if txt.split('.')[-1] != 'csv':
        print('Error - Exiting - Not a CSV file')
        sys.exit(0)

print(f'{datetime.datetime.now()} - Info - Importing CSV')

try:
  inputfile = pandas.read_csv(sys.argv[1])
except:
  print(f'{datetime.datetime.now()} - Error - Exiting - CSV import failed')
  sys.exit(0)

print(f'{datetime.datetime.now()} - Info - Writing Parquet')

outputfile = txt.split('.')[0] + '.parquet'

inputfile.to_parquet(outputfile, compression='gzip')

print(f'{datetime.datetime.now()} - Complete - {outputfile} Written')
