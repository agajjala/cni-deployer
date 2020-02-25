import subprocess
from common import common


def validate_args(args):
    return None

def validate_config(args):
    validate_args(args)

    subprocess.run(
        ['terraform', 'validate'])
