from .common import run_command


def apply(manifest):
    command = ['terraform', 'apply', 'terraform_plan']

    return run_command(command, manifest)
