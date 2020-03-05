from .common import run_command


def destroy(manifest):
    command = ['terraform', 'destroy']

    return run_command(command, manifest)
