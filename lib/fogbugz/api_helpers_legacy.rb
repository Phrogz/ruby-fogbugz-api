module FogBugz
  
  module Api
    
    module Helpers
      module Legacy
        def filters
          execute_cmd('listFilters').xpath('//filter').inject({}) do |resp, f|
            name = f.text
            resp[name] = f.attributes.merge('name' => name)
            resp
          end
        end
        
        def projects(fWrite=false, ixProject=nil)
          b = builder.fWrite(1) if fWrite
          b.ixProject(ixProject) if ixProject
          list_process(execute_cmd('listProjects', builder), 'project', 'sProject')
        end
        
        private
        # method used by other list methods to process the XML returned by FogBugz API.
        #
        # * xml => XML to process
        # * element => individual elements within the XML to create Hashes for within the returned value
        # * element_name => key for each individual Hash within the return value.
        #
        # EXAMPLE XML
        #<response>
        #  <categories>
        #    <category>
        #      <ixCategory>1</ixCategory>
        #      <sCategory><![CDATA[Bug]]></sCategory>
        #      <sPlural><![CDATA[Bugs]]></sPlural>
        #      <ixStatusDefault>2</ixStatusDefault>
        #      <fIsScheduleItem>false</fIsScheduleItem>
        #    </category>
        #    <category>
        #      <ixCategory>2</ixCategory>
        #      <sCategory><![CDATA[Feature]]></sCategory>
        #      <sPlural><![CDATA[Features]]></sPlural>
        #      <ixStatusDefault>8</ixStatusDefault>
        #      <fIsScheduleItem>false</fIsScheduleItem>
        #    </category>
        #  </categories>
        #</response>
        #
        # EXAMPLE CAll
        # list_process(xml, "category", "sCategory")
        #
        # EXAMPLE HASH RETURN
        #
        # {
        #   "Bug" => {
        #     "ixCategory" => 1,
        #     "sCategory" => "Bug",
        #     "sPlural" => "Bugs",
        #     "ixStatusDefault" => 2,
        #     "fIsScheduleItem" => false
        #   },
        #     "Feature" => {
        #     "ixCategory" => 2,
        #     "sCategory" => "Feature",
        #     "sPlural" => "Features",
        #     "ixStatusDefault" => 2,
        #     "fIsScheduleItem" => false
        #   }
        # }
        def list_process(xml, element, element_name)
          xml.xpath("//#{element}").inject({}) do |resp, elem|
            name = elem.xpath("#{element_name}").text
            resp[name] = {}
            elem.children.each do |c|
              unless c.text?
                resp[name][c.name] = convert_value(c)
              end
            end
            resp
          end
        end
        
        def convert_value(node)
          case node.name
            when /^(ix|n)/i
              node.text.to_i
            when /^f/
              node.text == 'false' ? false : true
            else
              node.text.to_s
          end
        end
      end
    
    end
  end
  
end