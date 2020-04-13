from .common import run_command


def validate(manifest, args):
    command = ['terraform', 'validate']

    return run_command(command, manifest)
