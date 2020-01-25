import subprocess
from common import common


def validate_args(args):
    assert('tvarspath' in args)


def delete_config(args):
    validate_args(args)
    destroy_plan = args['tfdir'] + common.generate_plan_filename(args['tfdir'], '_destroy')

    if args.get('auto') and int(args["auto"]) == 0:
        response = subprocess.run(['terraform', 'destroy', '-var-file', args['tvarspath']])
    else:
        response = subprocess.run(
            ['terraform', 'plan', '-destroy', '-var-file', args['tvarspath'], '-out', destroy_plan])
        print(response)
        if response.returncode == 0:
            response = subprocess.run(['terraform', 'apply', destroy_plan])
            print(response)

