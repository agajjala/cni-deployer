import argparse
import shlex
from common import common
from terraform.common import build_tf_env_vars


def export_to_environment(manifest_file_path):
    manifest = common.load_yaml(manifest_file_path)

    for key, value in build_tf_env_vars(manifest).items():
        print(f'export {key}={shlex.quote(value)}')


def print_outbound_vpc_suffixes(manifest_file_path):
    manifest = common.load_yaml(manifest_file_path)
    for vpc_suffix in manifest['outbound_vpcs_config'].keys():
        print(vpc_suffix)


def main():
    parser = argparse.ArgumentParser(
        description="This program wraps terraform to provide some additional flexibility")
    parser.add_argument(
        "-c", help='the helper command you want to run [export_to_env, print_outbound_vpc_suffixes]')
    parser.add_argument(
        "-manifest", help="path to the manifest to pass to the module")

    args = vars(parser.parse_args())

    if args['c'] == 'export_to_env':
        export_to_environment(args["manifest"])
    elif args['c'] == 'print_outbound_vpc_suffixes':
        print_outbound_vpc_suffixes(args["manifest"])
    else:
        raise(ValueError(args['c']))


if __name__ == '__main__':
    main()
