module ExportHelpers

  ASpaceExport::init
  
  

  def generate_marc(id)
    obj = resolve_references(Resource.to_jsonmodel(id), ['repository', 'linked_agents', 'subjects', 'tree'])
    #related_objects = obj['tree']['_resolved']['children']
    #tc = get_top_containers(related_objects)
    marc = ASpaceExport.model(:marc21).from_resource(JSONModel(:resource).new(obj))
    ASpaceExport::serialize(marc)
  end

  def get_top_containers(related_objects)
  	top_containers = {}
  	related_objects.each { |r|
     	obj = resolve_references(ArchivalObject.to_jsonmodel(r['id']), ['top_container'])
     	barcode =  obj['instances'][0]['sub_container']['top_container']['_resolved']['barcode']
     	top_containers[barcode] = obj['instances'][0]['sub_container']['top_container']['_resolved']['indicator']	
    }
    top_containers
  end

end

class MARCModel < ASpaceExport::ExportModel
  attr_reader :aspace_record, :top_containers

  def initialize(obj)
     @datafields = {}
     @aspace_record = obj
     id = 1
     t = resolve_references(ArchivalObject.to_jsonmodel(id), ['top_container'])
     binding.remote_pry
     #@top_containers = tc
  end


  def self.from_aspace_object(obj)
    self.new(obj)
  end

end

