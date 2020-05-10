import argparse
import json
import os
from common import common
from terraform.init import init
from terraform.validate import validate
from terraform.plan import plan
from terraform.apply import apply
from terraform.destroy import destroy
from terraform.refresh import refresh
from terraform.common import build_tf_env_vars


def parse_var(s):
    """
    Parse a key, value pair, separated by '='
    That's the reverse of ShellArgs.
    """
    items = s.split('=')
    key = items[0].strip() # we remove blanks around keys, as is logical
    value = ''
    if len(items) > 1:
        # rejoin the rest:
        value = '='.join(items[1:])

    return key, value


def parse_vars(items):
    """
    Parse a series of key-value pairs and return a dictionary
    """
    d = {}

    if items:
        for item in items:
            key, value = parse_var(item)
            d[key] = value
    return d


def validate_arguments(args):
    """
    args must have the terraform command and path to the .tf configuration file
    :param args:
    :return:
    """
    assert (args.get('c') is not None)
    assert (args.get('manifest') is not None)
    json.loads(args.get('manifest_override'))


def get_fixed_arguments(args):
    """
    return the fixed arguments as a dictionary
    :param args:
    :return:
    """
    return vars(args)


def export_tf_env_vars(manifest):
    for key, value in build_tf_env_vars(manifest):
        print(f'export {key}={value}')


def run(args):
    """
    run the terraform command specified by the user in the directory
    where the configuration file is located
    :param args:
    :return:
    """
    manifest = common.load_yaml(args['manifest'])
    additional_manifest = json.loads(args['manifest_override'])
    print(additional_manifest)
    manifest.update(additional_manifest)

    if args['c'] == 'init':
        init(manifest, args)
    elif args['c'] == 'validate':
        init(manifest, args)
        validate(manifest, args)
    elif args['c'] == 'plan':
        init(manifest, args)
        plan(manifest, args)
    elif args['c'] == 'apply':
        init(manifest, args)
        apply(manifest, args)
    elif args['c'] == 'destroy':
        init(manifest, args)
        destroy(manifest, args)
    elif args['c'] == 'refresh':
        init(manifest, args)
        refresh(manifest, args)
    elif args['c'] == 'export':
        export_tf_env_vars(manifest)


def main():
    parser = argparse.ArgumentParser(description="This program wraps terraform to provide some additional flexibility")
    parser.add_argument("-c", help='the terraform command you want to run [init, validate, plan, apply, destroy, refresh]')
    parser.add_argument("-module", help="path to the target module")
    parser.add_argument("-manifest", help="path to the manifest to pass to the module")
    parser.add_argument("-automation", help="enables automatic approval of commands that require approval", default=False, action='store_true')
    parser.add_argument("-manifest_override", help="Additional arguments as key value in json format", default="{}")

    args = parser.parse_args()
    deploy_args = get_fixed_arguments(args)

    print("Arguments: {}".format(deploy_args))
    validate_arguments(deploy_args)

    run(deploy_args)




if __name__=='__main__':
    main()
