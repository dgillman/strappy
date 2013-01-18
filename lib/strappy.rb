require 'mime'
require 'erb'
require 'tmpdir'

# Strappy creates a MIME multipart message for use with CloutInit
# Files are read from a template directory. If the file ends in .erb it is processed as an embedded Ruby template
# using the Binding context passed in by the caller of the processTemplates method. Files are assigned a MIME type
# based on comparing their first lines to those expected of the various file types. Any file that does not match
# one of the mappings will be given the text/plain type
class Strappy

  @@starts_with_mappings = {
    '#include'         => 'text/x-include-url',
    '#!'               => 'text/x-shellscript',
    '#cloud-config'   => 'text/cloud-config',
    '#upstart-job'    => 'text/upstart-job',
    '#part-handler'   => 'text/part-handler',
    '#cloud-boothook' => 'text/cloud-boothook'
  }

  # requires a directory containing templates and files to be place in the message
  def initialize( templateDir )
    @templateDir = templateDir
  end

  # resolves the type of file to one of those anticipated by CloutInit
  def getType( part )
    @@starts_with_mappings.each do |k, v|
      if part.start_with?(k) then
        return v
      end
    end

    return nil
  end

  # reads a .erb file and returns the template object
  def readTemplate (fileName)
    f = File.new(fileName)
    template = ERB.new(f.read)
    f.close

    return template
  end

  # processes the template directory, returning a MIME:MultipartMedia::Mixed message object
  def processTemplates(binding = Kernel.binding)

  	# .erb templates are processed into a temp directory; non-.erb files will be copied over
    Dir.mktmpdir ("strappy") { |dir|  
      Dir.foreach( @templateDir ) { |entry|
        templateFile = "#{@templateDir}/#{entry}"

        # skip anything that is not a file
        unless File.directory? (templateFile) then

        	# process templates
          if (matchData = entry.match('(.*)\.erb')) then  
            outName = matchData.captures[0]

            template = readTemplate(templateFile)
            File.open("#{dir}/#{outName}", mode="w+") do |tempFile|
              tempFile.write(template.result(binding))
            end
          else
          	# copy anything which is not a template directly
            FileUtils.cp templateFile, "#{dir}/#{entry}"
          end
        end
      }

      # new message object
      message = MIME::MultipartMedia::Mixed.new

      # process each file in the temp directory
      Dir.foreach ( dir ) { |entry|

        fileName = "#{dir}/#{entry}"

        unless File.directory? (fileName) then

        	# read file content
          f = File.new ("#{dir}/#{entry}")
          content = f.read
          f.close

          # determine type, defaulting to 'text/plain'
          type = "text/plain" unless (type = getType(content))

          # create a new part for the message and add it
          part = MIME::TextMedia.new(content, type)

          message.add_entity(part)
        end
      }

      return message
    }
  end
end
