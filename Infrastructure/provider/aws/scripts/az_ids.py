import sys
import json
import boto3

'''
  Utility to obtain a list of all availability zones for a given region.

  Expects a JSON as stdin of the following form:

  {
    "region": "us-west-2"
  }
'''

def parse_input_json():
    query_string = sys.stdin.read()
    query = json.loads(query_string)
    return query

def main():
    query = parse_input_json()

    if 'region' not in query:
        raise ValueError('"region" is missing from JSON')

    ec2 = boto3.client('ec2', region_name=query['region'])
    response = ec2.describe_availability_zones()

    az_ids = [az['ZoneId'] for az in response['AvailabilityZones']]
    az_ids.sort()

    output = {
      'az_ids': ','.join(az_ids)
    }

    print(json.dumps(output))

if __name__ == '__main__':
    main()
