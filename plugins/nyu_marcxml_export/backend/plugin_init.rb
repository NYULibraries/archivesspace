require_relative 'lib/aspace_patches'
require_relative 'lib/marc_custom_field_serialize'


MARCSerializer.add_decorator(MARCCustomFieldSerialize)