require 'spec_helper'

describe 'NYU Custom Marcxml Export' do 
 
	describe 'datafield 853 mapping' do
	  
	  before(:each) do
	  	 opts = {:title => generate(:generic_title)}
	    @resource = create_resource(opts)
	    @marc = get_marc(@resource)
	  end

	 it 'should have the correct indicator attribute values' do
	 	@marc.should have_tag("datafield[@tag='853'][@ind1='0'][@ind2='0']")
    end

	 it "maps the value '1' to subfield '8'" do
      @marc.should have_tag "datafield[@tag='853']/subfield[@code='8']" => '1'
    end

    it "maps the value 'Box' to subfield 'a'" do
      @marc.should have_tag "datafield[@tag='853']/subfield[@code='a']" => 'Box'
    end

   end

   describe 'datafield 863 mapping' do
     # default create behavior is to 
     # create arbitrary indicator and barcode values
     let (:top_container) { create(:json_top_container) }
	  before(:each) do
	  	 resource = create_resource
	  	 archival_object = create(:json_archival_object, 
	  	  		                    "resource" => {"ref" => resource.uri},
	  	  	                       :level => "file", 
	  	  	                       "instances" => [build_instance(top_container)])
	    @marc = get_marc(resource)
	  end

	  it 'should have the correct indicator attribute values' do
	 	@marc.should have_tag("datafield[@tag='863'][@ind1=''][@ind2='']")
     end

	  # these marc fields should exist whether or not barcode is there
     it "concatenates '1.' with the indicator value to subfield '8'" do
        @marc.should have_tag "datafield[@tag='863']/subfield[@code='8']" => "1.#{top_container.indicator}"
     end

     it "maps the indicator value to subfield 'a'" do
        @marc.should have_tag "datafield[@tag='863']/subfield[@code='a']" => "#{top_container.indicator}"
     end

     it "maps the barcode value to subfield 'p' if barcode exists" do
       @marc.should have_tag "datafield[@tag='863']/subfield[@code='p']" => "#{top_container.barcode}"
     end
  	  context 'there is no barcode in the top container' do
  		 let (:barcode)    { nil }
	  	 let (:top_container) { create(:json_top_container, 'barcode' => barcode) }
	  	 before(:each) do
	  	  	resource = create_resource
	  	  	archival_object = create(:json_archival_object, 
	  	  		                      "resource" => {"ref" => resource.uri},
	  	  	                         :level => "file", 
	  	  	                         "instances" => [build_instance(top_container)])
	      @marc = get_marc(resource)
	    end
       it "subfield 'p' should not exist without a barcode" do
         @marc.should_not have_tag("datafield[@tag='863']/subfield[@code='p']")
       end
     end
   end

   #describe 'datafield 949 mapping' do

   #end
end