module ExportHelpers

  ASpaceExport::init
  
  

  def generate_marc(id)
    obj = resolve_references(Resource.to_jsonmodel(id), ['repository', 'linked_agents', 'subjects', 'tree'])
    marc = ASpaceExport.model(:marc21).from_resource(JSONModel(:resource).new(obj))
    ASpaceExport::serialize(marc)
  end


end

class MARCModel < ASpaceExport::ExportModel
  attr_reader :aspace_record

  def initialize(obj)
     @datafields = {}
     @aspace_record = obj
     #test = resolve_references(Resource.to_jsonmodel(id), ['repository', 'linked_agents', 'subjects', 'tree'])
  end


  def self.from_aspace_object(obj)
    self.new(obj)
  end

end

