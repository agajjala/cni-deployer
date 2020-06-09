from .common import get_plan_name
from .common import run_command


def apply(manifest, args):
    command = ['terraform', 'apply']

    if args['automation'] is True:
        command.append('-auto-approve')
        command.append('-no-color')

    command.append(get_plan_name(manifest))

    return run_command(command, manifest)
