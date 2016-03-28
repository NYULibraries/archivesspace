require 'spec_helper'

describe 'NYU Custom Marcxml Export' do 
 
	describe 'datafield 853 mapping' do
	  
	  before(:each) do
	  	 opts = {:title => generate(:generic_title)}
	    @resource = create_resource(opts)
	    @marc = get_marc(@resource)
	  end


	  it "maps the value '1' to subfield '8'" do
      @marc.should have_tag "datafield[@tag='853']/subfield[@code='8']" => '1'
    end

    it "maps the value 'Box' to subfield 'a'" do
      @marc.should have_tag "datafield[@tag='853']/subfield[@code='a']" => 'Box'
    end
   end

   describe 'datafield 863 mapping' do
     let (:indicator)  { '1' }
	  context 'there is a barcode in the top container' do
	  	  let (:barcode)    { '1234567'}
	  	  let (:top_container) { create(:json_top_container, 'barcode' => barcode, 'indicator' => indicator) }
	  	  before(:each) do
	  	  	resource = create_resource
	  	  	archival_object = create(:json_archival_object, 
	  	  		                     "resource" => {"ref" => resource.uri},
	  	  	                         :level => "file", 
	  	  	                         "instances" => [build_instance(top_container)])
	       @marc = get_marc(resource)
	     end


	     it "concatenates '1.' with the indicator value to subfield '8'" do
          @marc.should have_tag "datafield[@tag='863']/subfield[@code='8']" => "1.#{indicator}"
          binding.remote_pry
        end

        it "maps the indicator value to subfield 'a'" do
          @marc.should have_tag "datafield[@tag='863']/subfield[@code='a']" => "#{indicator}"
        end

    	  it "map the barcode value to subfield 'p' if barcode exists" do
          @marc.should have_tag "datafield[@tag='863']/subfield[@code='p']" => "#{barcode}"
        end
      end
   end
end