import sys
import pandas
import datetime

txt = str(sys.argv[1])

print(f'{datetime.datetime.now()} - Info - CSV to Parquet conversion - Starting File Name {txt}')

if txt.split('.')[-1] != 'csv':
        print('Error - Exiting - Not a CSV file')
        sys.exit(0)

print(f'{datetime.datetime.now()} - Ok - Importing CSV')

inputfile = pandas.read_csv(sys.argv[1])

print(f'{datetime.datetime.now()} - Ok - Writing Parquet')

outputfile = txt.split('.')[0] + '.parquet'

inputfile.to_parquet(outputfile, compression='gzip')

print(f'{datetime.datetime.now()} - Complete - {outputfile} Written')
