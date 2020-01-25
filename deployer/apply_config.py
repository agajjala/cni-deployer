import subprocess
from common import common


def validate_args(args):
    assert('tvarspath' in args)


def apply_config(args):
    validate_args(args)
    apply_plan = args['tfdir']+common.generate_plan_filename(args['tfdir'], '_apply')

    if args.get('auto') and int(args["auto"]) == 0:
        response = subprocess.run(['terraform', 'apply', '-var-file', args['tvarspath']])
    else:
        response = subprocess.run(
            ['terraform', 'plan', '-var-file', args['tvarspath'], '-out', apply_plan])
        print(response)
        if response.returncode == 0:
            response = subprocess.run(['terraform', 'apply', apply_plan])
            print(response)
