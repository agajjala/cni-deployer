from .common import get_plan_name
from .common import run_command


def plan(manifest, args):
    command = ['terraform', 'plan', '-out', get_plan_name(manifest)]

    if 'automation' in args:
        command.append('-no-color')
        command.append('-detailed-exitcode')

    return run_command(command, manifest)
