import os
import json
import subprocess
import glob

def load_config(json_filename):
    with open(json_filename, 'r') as f:
        config = json.load(f)
        return config


def init(args):
    tfvars = load_config(args['tfvars'])
    backend_config = load_config('backend_config.json')

    init_arguments = []
    for key, value in backend_config.items():
        init_arguments.append('-backend-config')
        arg = key + '=' + value.format(**tfvars)
        init_arguments.append(arg)

    init_arguments.insert(0, 'init')
    init_arguments.insert(0, 'terraform')
    response = subprocess.run(init_arguments)

    print(response, response.returncode)


def generate_plan_filename(path, suffix):
    config_file_name = os.path.basename(path)
    if config_file_name.endswith('/'):
        config_file_name = config_file_name[:-1]
    return '/'+config_file_name+suffix


def clear_local_state_cache():
    terraform_cache_dir = '{}/.terraform'.format(os.path.abspath(os.curdir))
    cached_state_files = glob.iglob(os.path.join(terraform_cache_dir, '*.tfstate'))

    if cached_state_files:
        print('Cleared local state cache.')
        for file in cached_state_files:
            os.remove(file)
