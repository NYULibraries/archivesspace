class MARCCustomFieldSerialize
  ControlField = Struct.new(:tag, :text)
  DataField = Struct.new(:tag, :ind1, :ind2, :subfields)
  SubField = Struct.new(:code, :text)
  Extra_fields = []
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
    add_853_tag
    #extra_fields << DataField.new('853', '0', '0', [SubField.new('8','1'),SubField.new('a','Box')])
    top_containers = @record.aspace_record['top_containers']
    top_containers.each_pair { |barcode, indicator|
      add_863_tag(barcode,indicator)
    }
    (@record.datafields + Extra_fields).sort_by(&:tag)

  end


  def add_853_tag
    Extra_fields << DataField.new('853', '0', '0', 
      [SubField.new('8','1'),SubField.new('a','Box')])
  end

  def add_863_tag(barcode, indicator)
    Extra_fields << DataField.new('863', '', '', 
      [SubField.new('8',"1.#{indicator}"),
        SubField.new('a',indicator),
        SubField.new('p',barcode)])
  end

  def add_949_tag(extra_fields, barcode, indicator)
    extra_fields << DataField.new('863', '', '', [SubField.new('8',"1.#{indicator}"),SubField.new('a',indicator),SubField.new('p',barcode)])
  end
end