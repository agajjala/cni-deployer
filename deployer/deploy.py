
import os
import argparse
from validate_config import validate_config
from plan_config import plan_config
from apply_config import apply_config
from delete_config import delete_config


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
    assert (args.get('module') is not None)


def get_fixed_arguments(args):
    """
    return the fixed arguments as a dictionary
    :param args:
    :return:
    """
    return vars(args)


def run(args):
    """
    run the terraform command specified by the user in the directory
    where the configuration file is located
    :param args:
    :return:
    """
    # change dir to where the .tf file is
    os.chdir(args['module'])
    module_dir = os.path.abspath(os.curdir)
    print('Changed directory to: {}'.format(module_dir))
    assert(module_dir.endswith(os.path.basename(args['module'])))

    # check which terraform command is being used and call related function
    if args['c'] == 'validate':
        validate_config(args)
    if args['c'] == 'plan':
        plan_config(args)
    elif args['c'] == 'apply':
        apply_config(args)
    elif args['c'] == 'destroy':
        delete_config(args)


def main():
    parser = argparse.ArgumentParser(description="This program wraps terraform to provide some additional flexibility")
    parser.add_argument("-c", help='the terraform command you want to run [validate, plan, apply, destroy]')
    parser.add_argument("-module", help="absolute path to the target module")
    parser.add_argument("-tfvars", help="absolute path to the tfvars.json to pass to the module")
    parser.add_argument("--set",
                        metavar="KEY=VALUE",
                        nargs='+',
                        help="Set a number of key-value pairs "
                             "(do not put spaces before or after the = sign). "
                             "If a value contains spaces, you should define "
                             "it with double quotes: "
                             'foo="this is a sentence". Note that '
                             "values are always treated as strings.")

    args = parser.parse_args()
    terraform_arguments = get_fixed_arguments(args)

    if args.set:
        terraform_arguments = parse_vars(args.set)

    print("values:{}".format(terraform_arguments))
    validate_arguments(terraform_arguments)

    run(terraform_arguments)


if __name__=='__main__':
    main()
