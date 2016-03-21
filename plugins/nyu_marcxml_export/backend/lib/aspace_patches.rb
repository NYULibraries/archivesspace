module ExportHelpers

  ASpaceExport::init
  
  

  def generate_marc(id)
    obj = resolve_references(Resource.to_jsonmodel(id), ['repository', 'linked_agents', 'subjects', 'tree'])
    related_objects = obj['tree']['_resolved']['children']
    #obj[:top_containers] = get_top_containers(related_objects) if related_objects
    tc = get_top_containers(related_objects) if related_objects
    if tc
      obj[:top_containers]= get_locations(tc) 
    end
    binding.remote_pry
    marc = ASpaceExport.model(:marc21).from_resource(JSONModel(:resource).new(obj))
    ASpaceExport::serialize(marc)
  end

  def get_top_containers(related_objects)
  	top_containers = {}
  	related_objects.each { |r|
     	obj = resolve_references(ArchivalObject.to_jsonmodel(r['id']), ['top_container'])
      tc_id = obj['instances'][0]['sub_container']['top_container']['ref'].split('/')[4].to_i
     	barcode =  obj['instances'][0]['sub_container']['top_container']['_resolved']['barcode'] if barcode
      indicator = obj['instances'][0]['sub_container']['top_container']['_resolved']['indicator'] 
     	bc = {barcode: barcode} if barcode
      unless indicator
        raise "ERROR: Indicator should exist"
      end
      ind = {indicator: indicator}
      tc_info = barcode.nil? ? ind : ind.merge(bc)
      top_containers[tc_id] = tc_info
    }
    top_containers
  end

  def get_locations(top_containers)
    location = {}
    tc = top_containers.dup
    top_containers.each_key { |t|
      obj = resolve_references(TopContainer.to_jsonmodel(t), ['container_locations'])
      building = obj['container_locations'][0]['_resolved']['building']
      unless  building
        raise "ERROR: Container information for top container: #{t} must exist"
      end
      location = {location: building} 
      tc[t] = top_containers[t].merge(location)
    }
    tc

  end

end

class MARCModel < ASpaceExport::ExportModel
  attr_reader :aspace_record

  def initialize(obj)
     @datafields = {}
     @aspace_record = obj
  end


  def self.from_aspace_object(obj)
    self.new(obj)
  end

end

