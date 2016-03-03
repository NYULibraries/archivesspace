class MARCCustomFieldSerialize
  ControlField = Struct.new(:tag, :text)
  DataField = Struct.new(:tag, :ind1, :ind2, :subfields)
  SubField = Struct.new(:code, :text)
  
  def initialize(record)
    @record = record
    #binding.remote_pry
  end

   def datafields
      @record
      binding.remote_pry
   end
end