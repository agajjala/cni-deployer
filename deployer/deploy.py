
import os
import argparse
import subprocess
from apply_config import apply_config
from delete_config import delete_config
from common import common


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
    assert (args.get('tfdir') is not None)
    assert (args.get('tfvarspath') is not None)



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
    os.chdir(args['tfdir'])
    print('Changed directory to :{}'.format(os.path.abspath(os.curdir)))
    assert(os.path.abspath(os.curdir).endswith(os.path.basename(args['tfdir'])))

    common.init(args)

    # check which terraform command is being used and call related function
    if args['c'] == 'apply':
        apply_config(args)
    elif args['c'] == 'destroy':
        delete_config(args)


def main():
    parser = argparse.ArgumentParser(description="This program wraps terraform to provide some additional flexibility")
    parser.add_argument("-c", help='the terraform command you want to run')
    parser.add_argument("-tfdir", help="directory of the .tf file")
    parser.add_argument("-tfvarspath", help="path to the tfvars.json file path")
    parser.add_argument("-auto", help="0: will prompt the user 1: will apply the generated plan", default='0')
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
