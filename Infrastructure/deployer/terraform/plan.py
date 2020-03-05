from .common import run_command


def plan(manifest):
    command = ['terraform', 'plan', '-out', 'terraform_plan']

    return run_command(command, manifest)
