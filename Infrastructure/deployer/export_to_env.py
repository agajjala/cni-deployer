import argparse
import shlex
from common import common
from terraform.common import build_tf_env_vars

def main():
    parser = argparse.ArgumentParser(description="This program wraps terraform to provide some additional flexibility")
    parser.add_argument("-manifest", help="path to the manifest to pass to the module")

    args = parser.parse_args()

    manifest = common.load_yaml(args.manifest)

    for key, value in build_tf_env_vars(manifest).items():
        print(f'export {key}={shlex.quote(value)}')


if __name__=='__main__':
    main()
