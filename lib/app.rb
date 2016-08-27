
require 'haml'

class App
  attr_accessor :root_path, :layout_path

  def initialize root_path, layout_path = nil
    @root_path = root_path
    @layout_path = layout_path || File.expand_path("layout.haml", root_path)
  end

  def layout page
    if File.file?(layout_path)
      layout_file = File.read(layout_path)
      layout = Haml::Engine.new(layout_file)
      layout.render do
        if page.respond_to? :render
          page.render
        else
          page
        end
      end
    else
      if page.respond_to? :render
        page.render
      else
        page
      end
    end
  end

  def call env
    headers = { 'Content-Type'  => 'text/html' }
    request = Rack::Request.new(env)

    code = 404
    content = 'Not Found.'

    path = '.' + request.path_info #[1..-1] ## remove leading /
    path = File.expand_path(path, root_path)

    # stat = File.stat(path)
    # if stat.file? 
    #   return [200, headers, File.read(path)]
    # end

    if File.directory? path
      path = File.expand_path('index', path)
    end

    html_path = path + '.html'
    haml_path = path + '.haml'

    if File.file?( haml_path )
      content = Haml::Engine.new(File.read(haml_path))
      code = 200
    end

    [ code, headers, [layout(content)] ]
  end
end
