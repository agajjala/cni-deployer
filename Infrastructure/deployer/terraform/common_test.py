from common import *


class TestCommon:
    def test_build_tf_env_vars(self):
        manifest = {
            'empty': None,
            'string': 'foo',
            'numeric': 3.14,
            'bool': True,
            'array_of_strings': ['foo', 'bar'],
            'array_of_numerics': [3.14],
            'array_of_bools': [True],
            'map_of_strings': {'foo': 'bar'},
            'map_of_numerics': {'pi': 3.14},
            'map_of_bools': {'true': True}
        }
        tf_env_vars = build_tf_env_vars(manifest)

        key = 'TF_VAR_empty'
        assert key in tf_env_vars
        assert tf_env_vars[key] == ''

        key = 'TF_VAR_string'
        assert key in tf_env_vars
        assert tf_env_vars[key] == 'foo'

        key = 'TF_VAR_numeric'
        assert key in tf_env_vars
        assert tf_env_vars[key] == '3.14'

        key = 'TF_VAR_bool'
        assert key in tf_env_vars
        assert tf_env_vars[key] == 'true'

        key = 'TF_VAR_array_of_strings'
        assert key in tf_env_vars
        assert tf_env_vars[key] == '["foo", "bar"]'

        key = 'TF_VAR_array_of_numerics'
        assert key in tf_env_vars
        assert tf_env_vars[key] == '[3.14]'

        key = 'TF_VAR_array_of_bools'
        assert key in tf_env_vars
        assert tf_env_vars[key] == '[true]'

        key = 'TF_VAR_map_of_strings'
        assert key in tf_env_vars
        assert tf_env_vars[key] == '{foo = "bar"}'

        key = 'TF_VAR_map_of_numerics'
        assert key in tf_env_vars
        assert tf_env_vars[key] == '{pi = 3.14}'

        key = 'TF_VAR_map_of_bools'
        assert key in tf_env_vars
        assert tf_env_vars[key] == '{true = true}'

    def test_serialize_to_hcl_string(self):
        empty_value = None
        assert serialize_to_hcl_string(empty_value) == ''

        empty_string = ""
        assert serialize_to_hcl_string(empty_string) == ''

        empty_list = []
        assert serialize_to_hcl_string(empty_list) == '[]'

        empty_map = {}
        assert serialize_to_hcl_string(empty_map) == '{}'

        string = "foo"
        assert serialize_to_hcl_string(string) == 'foo'

        numeric = 3.14
        assert serialize_to_hcl_string(numeric) == '3.14'

        bool = True
        assert serialize_to_hcl_string(bool) == 'true'

        list_of_strings = ['foo', 'bar']
        assert serialize_to_hcl_string(list_of_strings) == '["foo", "bar"]'

        list_of_numerics = [3.14]
        assert serialize_to_hcl_string(list_of_numerics) == '[3.14]'

        list_of_bools = [True]
        assert serialize_to_hcl_string(list_of_bools) == '[true]'

        list_of_lists = [['foo', 'bar'], ['alpha', 'bravo']]
        assert serialize_to_hcl_string(list_of_lists) == '[["foo", "bar"], ["alpha", "bravo"]]'

        list_of_maps = [{'foo': 'bar'}, {'alpha': 'bravo'}]
        assert serialize_to_hcl_string(list_of_maps) == '[{foo = "bar"}, {alpha = "bravo"}]'

        map_of_strings = {'foo': 'bar'}
        assert serialize_to_hcl_string(map_of_strings) == '{foo = "bar"}'

        map_of_numerics = {'pi': 3.14}
        assert serialize_to_hcl_string(map_of_numerics) == '{pi = 3.14}'

        map_of_bools = {'true': True}
        assert serialize_to_hcl_string(map_of_bools) == '{true = true}'

        map_of_lists = {'foo': ['alpha', 'bravo'], 'bar': ['charlie', 'delta']}
        assert serialize_to_hcl_string(map_of_lists) == '{foo = ["alpha", "bravo"], bar = ["charlie", "delta"]}'

        map_of_maps = {'foo': {'alpha': 'bravo'}, 'bar': {'charlie': 'delta'}}
        assert serialize_to_hcl_string(map_of_maps) == '{foo = {alpha = "bravo"}, bar = {charlie = "delta"}}'
