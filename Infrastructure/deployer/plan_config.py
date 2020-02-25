import subprocess
from common import common


def validate_args(args):
    assert('manifest' in args)


def plan_config(args):
    validate_args(args)

    common.clear_local_state_cache()
    common.init(args)

    subprocess.run(
        ['terraform', 'plan', '-var-file', args['manifest'], '-out', 'terraform_plan'])
