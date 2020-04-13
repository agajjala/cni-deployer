from .common import run_command


def refresh(manifest, args):
    command = ['terraform', 'refresh']

    return run_command(command, manifest)
