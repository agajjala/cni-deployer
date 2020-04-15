from .common import run_command


def apply(manifest, args):
    command = ['terraform', 'apply']

    if args['automation'] is True:
        command.append('-auto-approve')

    command.append('terraform_plan')

    return run_command(command, manifest)
