import glob
import json
import os
from .common import run_command

BACKEND_CONFIG_FILENAME = 'backend_config.json'


def clear_local_state_cache():
    """
    Removes all *.tfstate files in the Terraform cache directory. This method should be called before every invocation
    of "terraform init" to ensure the state backend can be dynamically re-configured. Otherwise, an existing state file
    sourced from a different manifest can produce unexpected results when running Terraform commands.
    """
    terraform_cache_dir = f'{os.path.abspath(os.curdir)}/.terraform'
    cached_state_files = glob.iglob(os.path.join(terraform_cache_dir, '*.tfstate'))

    if cached_state_files:
        for file in cached_state_files:
            os.remove(file)
        print('Cleared local state cache.')


def load_config(json_filename):
    with open(json_filename, 'r') as f:
        config = json.load(f)
        return config


def build_backend_config_args(manifest):
    args = []
    if os.path.isfile(BACKEND_CONFIG_FILENAME):
        backend_config = load_config(BACKEND_CONFIG_FILENAME)
        for key, value in backend_config.items():
            args.append('-backend-config')
            arg = key + '=' + value.format(**manifest)
            args.append(arg)
    return args


def init(manifest, args):
    """
    Initializes Terraform using a dynamic state backend. This dynamism allows Terraform to read and write to a different
    state file based on the provided manifest.
    """
    module_path = args['module']
    os.chdir(module_path)

    clear_local_state_cache()

    backend_config_args = build_backend_config_args(manifest)

    command = ['terraform', 'init'] + backend_config_args

    if args['automation'] is True:
        command.append('-no-color')

    return run_command(command, manifest)
