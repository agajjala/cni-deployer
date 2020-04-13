from .common import run_command


def destroy(manifest, args):
    command = ['terraform', 'destroy']

    if 'automation' in args:
        command.append('-auto-approve')

    return run_command(command, manifest)
