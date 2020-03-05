import yaml


def load_yaml(filepath):
    with open(filepath, 'r') as f:
        data = yaml.safe_load(f)
        return data
