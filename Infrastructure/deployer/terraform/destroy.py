from .common import run_command


def destroy(manifest, args):
    command = ['terraform', 'destroy']

    if args['automation'] is True:
        command.append('-auto-approve')
        command.append('-no-color')

    return run_command(command, manifest)
