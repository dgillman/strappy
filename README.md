Strappy creates a MIME multipart message for use with [CloutInit](https://help.ubuntu.com/community/CloudInit). Files are read from a template directory. If the file ends in .erb it is processed as an embedded Ruby template using the Binding context passed in by the caller of the processTemplates method. Files are assigned a MIME type based on comparing their first lines to those expected of the various file types. Any file that does not match one of the mappings will be given the text/plain type.

# Usage

1. Create a new Strappy object. You must pass it a directory path.
2. Initialize any variables that you would like to make available to the ERB processor when processing templates
3. Call strappy.processTemplates with a [Binding](http://www.ruby-doc.org/core-1.9.3/Binding.html) object. Use a call to binding() to get the current context.

```
  templateDirectory = "/path/to/a/directory"
  strappy = Strappy.new(templateDirectory)
  contextVariable = "this is a test"
  result = strappy.processTemplates(binding())		
```