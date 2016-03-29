require 'spec_helper'

def create_resource_with_repo_id(repo_id)
	Resource.create_from_json(build(:json_resource), :repo_id => repo_id)
end

def create_top_container_with_location(bldg, resource_uri)
	unless bldg and resource_uri
		raise "ERROR: need values for bldg and resource_uri"
	end
	location = create(:json_location, :building => bldg)
   loc_hash = {'ref' => location.uri, 'status' => 'current', 'start_date' => '2000-01-01' }
   loc_top_container = create(:json_top_container,
        								'container_locations' => [loc_hash]
        							  )
   create_archival_object(loc_top_container, resource_uri)
end

def create_archival_object(top_container, resource_uri)
	create(:json_archival_object,
		    "resource" => {"ref" => resource_uri},
		    :level => "file",
		    "instances" => [build_instance(top_container)])
end

describe 'NYU Custom Marcxml Export' do 
 
	describe 'datafield 853 mapping' do
	  
	  before(:each) do
	    resource = create_resource
	    @marc = get_marc(resource)
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
     let (:repo_code) { 'tamwag' }
     let (:repo_id) { make_test_repo(code = repo_code) }
     let (:resource) { create_resource_with_repo_id(repo_id) }
	  before(:each) do
	  	 archival_object = create(:json_archival_object, 
	  	  		                    "resource" => {"ref" => resource.uri},
	  	  	                       :level => "file", 
	  	  	                       "instances" => [build_instance(top_container)])

	    @marc = get_marc(resource)
	  end

	  it 'should have the correct indicator attribute values' do
	 	@marc.should have_tag("datafield[@tag='863'][@ind1=''][@ind2='']")
     end

     it "concatenates '1.' with the top container indicator value to subfield '8'" do
        @marc.should have_tag "datafield[@tag='863']/subfield[@code='8']" => "1.#{top_container.indicator}"
     end

     it "maps the top container indicator value to subfield 'a'" do
        @marc.should have_tag "datafield[@tag='863']/subfield[@code='a']" => "#{top_container.indicator}"
     end

     it "maps the top container barcode value to subfield 'p' if barcode exists" do
       @marc.should have_tag "datafield[@tag='863']/subfield[@code='p']" => "#{top_container.barcode}"
     end

  	  context 'there is no barcode in the top container' do
  		 let (:barcode)    { nil }
	  	 let (:top_container) { create(:json_top_container, 'barcode' => barcode) }
	  	 let (:resource) { create_resource_with_repo_id(repo_id) }
	  	 before(:each) do
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

   describe 'datafield 949 mapping' do
   	let (:top_container) { create(:json_top_container) }
   	let (:repo_code) { 'tamwag' }
   	let (:repo_id) { make_test_repo(code = repo_code) }
   	let (:resource) { create_resource_with_repo_id(repo_id) }
	   before(:each) do
	  	  archival_object = create(:json_archival_object, 
	  	  		                    "resource" => {"ref" => resource.uri},
	  	  	                       :level => "file", 
	  	  	                       "instances" => [build_instance(top_container)])
	     @marc = get_marc(resource)
	  end
	   it "has the correct indicator attribute values" do
	 	   @marc.should have_tag("datafield[@tag='949'][@ind1='0'][@ind2='']")
      end

      it "maps 'NNU' to subfield 'a'" do
	 	  @marc.should have_tag "datafield[@tag='949']/subfield[@code='a']" => "NNU"
      end

      it "maps '4' to subfield 't'" do
	 	  @marc.should have_tag "datafield[@tag='949']/subfield[@code='t']" => "4"
      end

      it "maps 'MIXED' to subfield 'm'" do
	 	  @marc.should have_tag "datafield[@tag='949']/subfield[@code='m']" => "MIXED"
      end

      it "maps '04' to subfield 'i'" do
	 	  @marc.should have_tag "datafield[@tag='949']/subfield[@code='i']" => "04"
      end

      it "concatenates 'Box' to top container indicator value in subfield 'w'" do
        @marc.should have_tag "datafield[@tag='949']/subfield[@code='w']" => "Box #{top_container.indicator}"
      end

      it "maps top container indicator value to subfield 'e'" do
        @marc.should have_tag "datafield[@tag='949']/subfield[@code='e']" => "#{top_container.indicator}"
      end

      it "maps top container barcode value to subfield 'p'" do
        @marc.should have_tag "datafield[@tag='949']/subfield[@code='p']" => "#{top_container.barcode}"
      end

      it "there is no subfield 's' if there's no location information" do
         @marc.should_not have_tag ("datafield[@tag='949']/subfield[@code='s']")
   	end
        
      it "maps 'VH' if building location is 'Clancy Cullen' to subfield 's'" do
  	      create_top_container_with_location("Clancy Cullen",resource.uri)
	      @marc = get_marc(resource)
	      @marc.should have_tag "datafield[@tag='949']/subfield[@code='s']" => "VH"
      end

      it "maps '' to subfield 's' if location is other than Clancy Cullen" do
      	create_top_container_with_location("foo",resource.uri)
	      @marc = get_marc(resource)
	      @marc.should have_tag "datafield[@tag='949']/subfield[@code='s']" => ""
      end

      it "maps 'BTAM' to subfield 'b'" do
      	@marc.should have_tag "datafield[@tag='949']/subfield[@code='b']" => "BTAM"
      end

      it "maps 'TAM' to subfield 'c'" do
      	@marc.should have_tag "datafield[@tag='949']/subfield[@code='c']" => "TAM"
      end

      describe 'check subfields for different repo codes' do
      	let (:top_container) { create(:json_top_container) }
      	context "if repo code is 'fales'" do
      		let (:repo_code) { 'fales' }
   			let (:repo_id) { make_test_repo(code = repo_code) }
   			let (:resource) { create_resource_with_repo_id(repo_id) }
	   		before(:each) do
	  	  			archival_object = create(:json_archival_object, 
	  	  		                     "resource" => {"ref" => resource.uri},
	  	  	                        :level => "file", 
	  	  	                        "instances" => [build_instance(top_container)])
	     			@marc = get_marc(resource)
	  			end
	  			it "maps 'BFALE' to subfield 'b'" do
      		  @marc.should have_tag "datafield[@tag='949']/subfield[@code='b']" => "BFALE"
      		end

      		it "maps 'FALES' to subfield 'c'" do
      			@marc.should have_tag "datafield[@tag='949']/subfield[@code='c']" => "FALES"
      		end
      	end
      	context "if repo code is 'archives'" do
      		let (:repo_code) { 'archives' }
   			let (:repo_id) { make_test_repo(code = repo_code) }
   			let (:resource) { create_resource_with_repo_id(repo_id) }
	   		before(:each) do
	  	  			archival_object = create(:json_archival_object, 
	  	  		                     "resource" => {"ref" => resource.uri},
	  	  	                        :level => "file", 
	  	  	                        "instances" => [build_instance(top_container)])
	     			@marc = get_marc(resource)
	  			end
	  			it "maps 'BOBST' to subfield 'b'" do
      		  @marc.should have_tag "datafield[@tag='949']/subfield[@code='b']" => "BOBST"
      		end

      		it "maps 'ARCH' to subfield 'c'" do
      			@marc.should have_tag "datafield[@tag='949']/subfield[@code='c']" => "ARCH"
      		end
      	end
      	context "if repo code is not amongst the allowed values" do
      		let (:repo_id) { make_test_repo(code = 'foo') }
   			let (:resource) { create_resource_with_repo_id(repo_id) }
      		it 'outputs an error message if repo code is not one of the allowed values' do 
	   			archival_object = create(:json_archival_object, 
	  	  		                         "resource" => {"ref" => resource.uri},
	  	  	                            :level => "file", 
	  	  	                            "instances" => [build_instance(top_container)])
	     	   	@marc = get_marc(resource)
	  				@marc.should have_tag("aspace_export_error")
      		end
      	end
      end
   end
end