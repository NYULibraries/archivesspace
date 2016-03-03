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

