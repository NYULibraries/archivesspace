class MARCCustomFieldSerialize
  ControlField = Struct.new(:tag, :text)
  DataField = Struct.new(:tag, :ind1, :ind2, :subfields)
  SubField = Struct.new(:code, :text)
  
  def initialize(record)
    @record = record
 
  end
   
  def leader_string
    result = @record.leader_string
  end

  def controlfield_string
    result = @record.controlfield_string
  end

  def datafields
    extra_fields = []
    extra_fields << DataField.new('853', '0', '0', [SubField.new('8','1'),SubField.new('a','Box')])
    tc = @record.aspace_record['top_containers']
    (@record.datafields + extra_fields).sort_by(&:tag)

  end

  #def add_853_tag
   # DataField.new('853', '0', '0', [SubField.new('8','1'),SubField.new('a','Box')])
  #end
end