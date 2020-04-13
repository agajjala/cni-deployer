import os
import subprocess
from subprocess import CompletedProcess, CalledProcessError


def build_tf_env_vars(manifest):
    """
    Parses the key-value pairs in manifest into a dictionary of environment variables of a format that can be consumed
    by Terraform. Keys are identical to keys in the manifest, except they are prefixed with "TF_VAR_". Values are
    converted into stringified HCL code.

    For more information on this format, see the following documentation on TF_VAR_name:
    https://www.terraform.io/docs/commands/environment-variables.html
    """
    tf_vars = {}
    for key, value in manifest.items():
        tf_var_key = 'TF_VAR_{}'.format(key)
        tf_vars[tf_var_key] = serialize_to_hcl_string(value)
    return tf_vars


def serialize_to_hcl_string(data):
    """
    Serializes Python maps, lists, and primitive types into an HCL string. This string is a valid value to provide for a
    TF_VAR environment variable consumed by Terraform.
    """
    return _serialize_to_hcl_string(data, True)


def _serialize_to_hcl_string(data, is_root):
    """
    Helper method to serialize Python maps, lists, and primitive types into an HCL string. In the case of maps and lists,
    this method calls itself recursively in order to serialize nested data.
    """
    if data is None:
        return ""
    elif isinstance(data, dict):
        key_value_pairs = [f"{key} = {_serialize_to_hcl_string(value, False)}" for key, value in data.items()]
        return f"{{{', '.join(key_value_pairs)}}}"
    elif isinstance(data, list):
        values = [_serialize_to_hcl_string(value, False) for value in data]
        return f"[{', '.join(values)}]"
    elif isinstance(data, bool):
        return f'{str(data).lower()}'
    elif is_root or isinstance(data, (int, float)):
        return f'{data}'
    elif isinstance(data, str):
        return f'"{data}"'
    else:
        raise Exception(f'Encountered unexpected type {type(data)} with value: {data}')


def run_command(command, manifest, base_env=os.environ):
    """
    Runs a Terraform command. The manifest is used to populate environment variables which are consumed by Terraform.
    """
    tf_env_vars = build_tf_env_vars(manifest)
    try:
        process: CompletedProcess = subprocess.run(command, env=dict(base_env, **tf_env_vars))
        process.check_returncode()
    except CalledProcessError as e:
        # Terraform returns an exit code of 1 if an error occurs
        if e.returncode == 1:
            exit(e.returncode)
