import argparse
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


def run_tf_command(manifest, args, tf_command):
    module_path = args['module']
    os.chdir(module_path)
    print('Changed directory to: {}'.format(module_path))

    init(manifest, args)
    tf_command(manifest, args)


def run(args):
    """
    run the terraform command specified by the user in the directory
    where the configuration file is located
    :param args:
    :return:
    """
    manifest = common.load_yaml(args['manifest'])

    if args['c'] == 'validate':
        run_tf_command(manifest, args, validate)
    if args['c'] == 'plan':
        run_tf_command(manifest, args, plan)
    elif args['c'] == 'apply':
        run_tf_command(manifest, args, apply)
    elif args['c'] == 'destroy':
        run_tf_command(manifest, args, destroy)
    elif args['c'] == 'refresh':
        run_tf_command(manifest, args, refresh)
    elif args['c'] == 'export':
        export_tf_env_vars(manifest)


def main():
    parser = argparse.ArgumentParser(description="This program wraps terraform to provide some additional flexibility")
    parser.add_argument("-c", help='the terraform command you want to run [validate, plan, apply, destroy, refresh]')
    parser.add_argument("-module", help="path to the target module")
    parser.add_argument("-manifest", help="path to the manifest to pass to the module")
    parser.add_argument("-automation", help="enables automatic approval of commands that require approval", default=False, action='store_true')

    args = parser.parse_args()
    deploy_args = get_fixed_arguments(args)

    print("Arguments: {}".format(deploy_args))
    validate_arguments(deploy_args)

    run(deploy_args)


if __name__=='__main__':
    main()
