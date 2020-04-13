from .common import run_command


def plan(manifest, args):
    command = ['terraform', 'plan', '-out', 'terraform_plan']

    if 'automation' in args:
        command.append('-detailed-exitcode')

    return run_command(command, manifest)
