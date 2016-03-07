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
    add_853_tag
    top_containers = @record.aspace_record['top_containers']
    top_containers.each_pair { |barcode, indicator|
      add_863_tag(barcode,indicator)
      add_949_tag(barcode, indicator)
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

  def add_949_tag(barcode, indicator)
    # missing sub s, need more info
    # about location
    # can there be a top container without a barcode, without an indicator?
    # can there be archival objects without a top container?
    sub_a = SubField.new('a','NNU')
    sub_m = SubField.new('m','MIXED')
    sub_t = SubField.new('t','4')
    sub_i = SubField.new('i','04')
    sub_p = SubField.new('p', barcode)
    sub_w = SubField.new('w',"Box #{indicator}")
    sub_e = SubField.new('e',indicator)
    j_id = @record.aspace_record['id_0']
    j_other_ids = []
    if @record.aspace_record['id_1'] and @record.aspace_record['id_2'] and @record.aspace_record['id_3']
      j_other_ids << @record.aspace_record['id_1']
      j_other_ids << @record.aspace_record['id_2']
      j_other_ids << @record.aspace_record['id_3']
      j_other_ids.unshift(j_id)
      j_other_ids.join(".")
    end
    # if no other ids, assign id_0 else assign the whole array of ids
    j_id = j_other_ids.size == 0 ? j_id : j_other_ids
    sub_j = SubField.new('j',j_id)
    
    subfields_b_c = {}
    sub_c = nil
    repo_code = {}
    case @record.aspace_record['repository']['_resolved']['repo_code']
    when 'tamwag'
      repo_code = { b: 'BTAM', c: 'TAM' }
    when 'fales'
      repo_code = { b: 'BFALE', c: 'FALES'}
    when 'archives'
      repo_code = { b: 'BOBST', c: 'ARCH' }
    when 'test'
      repo_code = { b: 'TEST', c: 'TEST' }
    else
      repo_code = { b: "ERROR - unrecognized code" }
    end
    repo_code.each_key{ |code|
      subfields_b_c[code] = SubField.new(code,repo_code[code])
    }
    Extra_fields << DataField.new('949','0','',
    [sub_a, subfields_b_c[:b], subfields_b_c[:c], sub_t, sub_j, sub_m, 
      sub_i, sub_p, sub_w, sub_e])
  end
end