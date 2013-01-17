require 'mime'
require 'erb'
require 'tmpdir'

class Strappy

  @@starts_with_mappings = {
    '#include'         => 'text/x-include-url',
    '#!'               => 'text/x-shellscript',
    '#cloud-config'   => 'text/cloud-config',
    '#upstart-job'    => 'text/upstart-job',
    '#part-handler'   => 'text/part-handler',
    '#cloud-boothook' => 'text/cloud-boothook'
  }

  def initialize( templateDir )
    @templateDir = templateDir
  end

  def getType( part )
    @@starts_with_mappings.each do |k, v|
      if part.start_with?(k) then
        return v
      end
    end

    return nil
  end

  def readTemplate (fileName)
    f = File.new(fileName)
    template = ERB.new(f.read)
    f.close

    return template
  end

  def processTemplates(binding = Kernel.binding)
    Dir.mktmpdir ("strappy") { |dir|  
      Dir.foreach( @templateDir ) { |entry|
        templateFile = "#{@templateDir}/#{entry}"
        unless File.directory? (templateFile) then
          if (matchData = entry.match('(.*)\.erb')) then  
            outName = matchData.captures[0]

            template = readTemplate(templateFile)
            File.open("#{dir}/#{outName}", mode="w+") do |tempFile|
              tempFile.write(template.result(binding))
            end
          else
            FileUtils.cp templateFile, "#{dir}/#{entry}"
          end
        end
      }

      message = MIME::MultipartMedia::Mixed.new

      Dir.foreach ( dir ) { |entry|

        fileName = "#{dir}/#{entry}"

        unless File.directory? (fileName) then

          f = File.new ("#{dir}/#{entry}")
          content = f.read
          f.close
          type = "text/plain" unless (type = getType(content))
          part = MIME::TextMedia.new(content, type)

          message.add_entity(part)
        end
      }

      return message
    }
  end
end
