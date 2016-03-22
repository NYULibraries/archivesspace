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
    if @record.aspace_record['top_containers']
      top_containers = @record.aspace_record['top_containers']
      top_containers.each_pair{ |id, info|
        add_863_tag(info)
        add_949_tag(info)
      }
    end
    (@record.datafields + Extra_fields).sort_by(&:tag)
     
  end

  # sorts keys by order
  # creates a new subfield instance
  def get_subfields(subfields_hsh)
    subfield_list = []
    subfields_hsh.keys.sort.each { |k|
      code = subfields_hsh[k][:code]
      value = subfields_hsh[k][:value]
      subfield_list << SubField.new(code,value)
    }
    subfield_list
  end

  def add_853_tag
    subfields_hsh = {}
    # have to have a hash by position as the key
    # since the subfield positions matter
    subfields_hsh[1] = {code: '8', value: '1' }
    subfields_hsh[2] = {code: 'a', value: 'Box' }
    subfield_list = get_subfields(subfields_hsh)
    Extra_fields << DataField.new('853', '0', '0', subfield_list)
  end

  def add_863_tag(info)
    subfields_hsh = {}
    # have to have a hash by position as the key
    # since the subfield positions matter
    subfields_hsh[1] = {code: '8', value: "1.#{info[:indicator]}" }
    subfields_hsh[2] = {code: 'a', value: info[:indicator] }
    subfields_hsh[3] = {code: 'p', value: info[:barcode] }  if info[:barcode]
    subfield_list = get_subfields(subfields_hsh)
    
    Extra_fields << DataField.new('863', '', '', subfield_list)
  end

  def add_949_tag(info)
    subfields_hsh = {}
    # have to have a hash by position as the key
    # since the subfield positions matter
    subfields_hsh[1] = {code: 'a', value: 'NNU'}
    subfields_hsh[6] = {code: 'm', value: 'MIXED'}
    subfields_hsh[4] = {code: 't', value: '4'}
    subfields_hsh[7] = {code: 'i', value: '04'}
    subfields_hsh[9] = {code: 'p', value: info[:barcode]} if info[:barcode]
    subfields_hsh[10] = {code: 'w', value: "Box #{info[:indicator]}" }
    subfields_hsh[11] = {code: 'e', value: info[:indicator]}
    subfields_hsh[5] = check_multiple_ids 
    subfields_hsh[8] = get_location(info[:location]) if info[:location]
    # merge repo code hash with existing subfield code hash
    subfields_hsh.merge!(get_repo_code_value)

    subfield_list = get_subfields(subfields_hsh)
    
    Extra_fields << DataField.new('949','0','',subfield_list)
  end

  def get_repo_code_value
    repo_code = {}
    subfields = {}
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
       position = code.to_s == 'b' ? 2 : 3
       subfields[position] = {code: code, value: repo_code[code]}
    }
    subfields

  end

  def check_multiple_ids
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

    {code: 'j', value: j_id } 

  end

  def get_location(location_info)
    location = location_info == 'Clancy Cullen' ? 'VH' : ''

    {code: 's', value: location }
  end

end