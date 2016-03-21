module ExportHelpers

  ASpaceExport::init
  
  

  def generate_marc(id)
    obj = resolve_references(Resource.to_jsonmodel(id), ['repository', 'linked_agents', 'subjects', 'tree'])
    related_objects = obj['tree']['_resolved']['children']
    containers = get_related_containers(related_objects) if related_objects
    if containers
      top_containers = get_top_containers(containers)
      obj[:top_containers]= get_locations(top_containers) 
    end
    marc = ASpaceExport.model(:marc21).from_resource(JSONModel(:resource).new(obj))
    ASpaceExport::serialize(marc)
  end

  def get_related_containers(related_objects)
  	related_containers = []
  	related_objects.each { |r|
     	obj = resolve_references(ArchivalObject.to_jsonmodel(r['id']), ['top_container'])
      related_containers << obj['instances']
    }
    related_containers
  end

  def get_top_containers(related_containers)
    top_containers = {}
    related_containers.each{ |containers|
      containers.each{ |t|
        tc_id = t['sub_container']['top_container']['ref'].split('/')[4].to_i
        barcode =  t['sub_container']['top_container']['_resolved']['barcode'] 
        indicator = t['sub_container']['top_container']['_resolved']['indicator'] 
        bc = {barcode: barcode} if barcode
        unless indicator
          raise "ERROR: Indicator should exist"
        end
        ind = {indicator: indicator}
        tc_info = barcode.nil? ? ind : ind.merge(bc)
        top_containers[tc_id] = tc_info
      }
    }
    top_containers
  end

  def get_locations(top_containers)
    location = {}
    tc = top_containers.dup
    top_containers.each_key { |t|
      obj = resolve_references(TopContainer.to_jsonmodel(t), ['container_locations'])
      unless  obj['container_locations'][0]
        raise "ERROR: Container information for top container: #{t} must exist"
      end
      building = obj['container_locations'][0]['_resolved']['building']
      unless  building
        raise "ERROR: Building information for top container: #{t} must exist"
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

