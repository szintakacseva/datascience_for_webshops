'''
Helper functions that create and execute sql queries on aws Athena. 
The input data for tables are extracted from csv files stored in aws S3.
The output of the queries (csv files) are downloaded to the local machine for further analysis in R.
'''
import getopt
import sys
import boto3
import configparser
import botocore

# checking the arguments
print('Argument List:', str(sys.argv))

sql = 'add_partition_whale'
client = '18947'

try:
    opts, args = getopt.getopt(sys.argv[1:], "hs:", ["sql="])
    print(opts, args)
except getopt.GetoptError:
    print('aws_athena_query.py -s<sql>')
    sys.exit()
else:
    for opt, arg in opts:
        if opt == '-h':
            print('aws_athena_query.py -s<sql>')
            sys.exit()
        elif opt in ("-s", "--sql"):
            sql = arg

# Function for creating named query
def create_named_query(client, name, query, database):
    response = client.create_named_query(Name=name, Database=database, QueryString=query)

    print('Execution ID: ' + response['NamedQueryId'])
    return response


# Function for getting named query
def get_named_query(client, queryid):
    response = client.get_named_query(NamedQueryId=queryid)

    print('Execution ID: ' + response['NamedQuery']['NamedQueryId'])
    return response


# Function for executing athena query
def run_query(client, query, database, s3_output):
    response = client.start_query_execution(QueryString=query, QueryExecutionContext={'Database': database},
        ResultConfiguration={'OutputLocation': s3_output, })
    print('Execution ID: ' + response['QueryExecutionId'])
    return response

# function for downloading the csv result from s3
def download_csv(s3, bucket, key, output):
    try:
        # s3.Bucket(BUCKET_NAME).download_file(KEY, '7447850f-73d0-49aa-b2ff-48e0220842d8.csv.gz')
        s3.Bucket(bucket).download_file(key, output)
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == "404":
            print("The object does not exist.")
        else:
            raise

# get aws credentials from aws.ini
aws_ini = configparser.RawConfigParser()
aws_ini.read('aws.ini')

aws_key = aws_ini.get('default', 'aws_key')
aws_secret = aws_ini.get('default', 'aws_secret')
aws_region = aws_ini.get('default', 'aws_region')

# define athena client
athena_client = boto3.client('athena', region_name=aws_region, aws_access_key_id=aws_key,
                             aws_secret_access_key=aws_secret)
# define s3 resource
s3 = boto3.resource('s3', aws_access_key_id=aws_key, aws_secret_access_key=aws_secret)

# Athena configuration
s3_input = 's3://bigdatatest.company.com/datapipeline/'
s3_output = 's3://aws-athena-query-results-089327134289-eu-west-1/'
database = 'insights'
table_whale = 'whale'
table_crab = 'crab'

# s3 configuration
BUCKET_NAME = 'aws-athena-query-results-089327134289-eu-west-1'
RESULTS_DIR = 'results'

# Query definitions
clientid = aws_ini.get('sql', 'tmp_clientid')
table = aws_ini.get('sql', 'tmp_table')

create_table_humpback = aws_ini.get('sql', 'create_table_humpback')
create_table_crab_dev = aws_ini.get('sql', 'create_table_crab_dev')
create_table_crab = aws_ini.get('sql', 'create_table_crab')
add_partition_whale = aws_ini.get('sql', 'add_partition_whale')
delete_partition_whale = aws_ini.get('sql', 'delete_partition_whale')
add_partition_crab = aws_ini.get('sql', 'add_partition_crab')
add_partition_crab_dev= aws_ini.get('sql', 'add_partition_crab_dev')
delete_partition_crab = aws_ini.get('sql', 'delete_partition_crab')
add_partition_crabtestsymd = aws_ini.get('sql', 'add_partition_crabtestsymd')
delete_partition_crabtestsymd = aws_ini.get('sql', 'delete_partition_crabtestsymd')
add_partition_humpback = aws_ini.get('sql', 'add_partition_humpback')
delete_partition_humpback = aws_ini.get('sql', 'delete_partition_humpback')
hourly_trafic_7days = aws_ini.get('sql', 'hourly_trafic_7days')
avg_json_per_minute_with_status = aws_ini.get('sql', 'avg_json_per_minute_with_status', raw=False)
weekdaily_yqm_status = aws_ini.get('sql', 'weekdaily_yqm_status')
extreme_sessiontimes = aws_ini.get('sql', 'extreme_sessiontimes')
weekdaily_month = aws_ini.get('sql', 'weekdaily_month')
avg_json_per_minute = aws_ini.get('sql', 'avg_json_per_minute')
kpi = aws_ini.get('sql', 'kpi')

# sql parameter substitution
avg_json_per_minute_with_status = avg_json_per_minute_with_status.replace('tmp_clientid', clientid)
avg_json_per_minute = avg_json_per_minute.replace('tmp_clientid', clientid)
kpi = kpi.replace('tmp_clientid', clientid)
#kpi = kpi.replace('tmp_table', table)

# create names, querynames dictionary
names = ['create_table_humpback', 'create_table_crab_dev', 'create_table_crab', 'add_partition_crab_dev', 'add_partition_crab',
         'delete_partition_crab','add_partition_whale', 'delete_partition_whale',
         'add_partition_crabtestsymd', 'delete_partition_crabtestsymd',  'add_partition_humpback', 'delete_partition_humpback',
         'hourly_trafic_7days', 'avg_json_per_minute_with_status', 'weekdaily_yqm_status',
         'extreme_sessiontimes', 'weekdaily_month', 'avg_json_per_minute', 'kpi']
queries = [create_table_humpback, create_table_crab_dev, create_table_crab, add_partition_crab_dev, add_partition_crab,
           delete_partition_crab, add_partition_whale, delete_partition_whale,
           add_partition_crabtestsymd, delete_partition_crabtestsymd,  add_partition_humpback, delete_partition_humpback,
           hourly_trafic_7days, avg_json_per_minute_with_status, weekdaily_yqm_status, extreme_sessiontimes,
           weekdaily_month, avg_json_per_minute, kpi]
queries_dict = dict(zip(names, queries))

if sql == 'all':
    # executing all the queries
    for name, query in queries_dict.items():
        print("Executing query: %s" % (name))
        res = run_query(athena_client, query, database, s3_output + name)
elif sql in names:
    # exec the query specified as commanline argument
    print("Executing query: %s" % sql)
    res = run_query(athena_client, queries_dict[sql], database, s3_output + sql)
else:
    # Do the default
    print("Nothing TO DO !!!")

BUCKET_NAME = 'aws-athena-query-results-089327134289-eu-west-1'  # replace with your bucket name
# KEY = 'average_json_per_minute/2017/11/10/7f907865-c60d-4322-b4dc-c92bf14f4e67.csv'  # replace with your object key
KEY = 'results/ce8a8f04-670d-44eb-a852-8ae6c67c11c4.csv'
output_csv = 'valami3.csv'
download_csv(s3, BUCKET_NAME, KEY, output_csv)
