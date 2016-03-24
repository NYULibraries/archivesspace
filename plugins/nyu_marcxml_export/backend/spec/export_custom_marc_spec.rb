require 'spec_helper'

describe 'NYU Custom Marcxml Export' do 
 
	describe 'datafield 853 mapping'
	  
	  before(:all) do
	  	 opts = {:title => generate(:generic_title)}
	    @resource = create_resource(opts)
	    @marc = get_marc(@resource)
	  end

	  it "maps the value 1 to subfield '8'" do
      @marc.should have_tag "datafield[@tag='853']/subfield[@code='8']" => 1
    end

    it "maps the value 'Box' to subfield 'a'" do
      @marc.should have_tag "datafield[@tag='853']/subfield[@code='a']" => 'Box'
    end

   end

   describe 'datafield 863 mapping'
   	before(:all) do
	  	 opts = {:title => generate(:generic_title)}
	    @resource = create_resource(opts)
	    @marc = get_marc(@resource)

	    # check mapping with barcode
	    # check mapping without barcode
	    # if no top container, this shouldn't exist
	  end

   end
end
