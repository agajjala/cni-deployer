import os
import json
import subprocess


def load_config(json_filename):
    with open(json_filename, 'r') as f:
        config = json.load(f)
        return config


def init(args):
    tfvars = load_config(args['tfvarspath'])
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
    return '/'+config_file_name+suffix
